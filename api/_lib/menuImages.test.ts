import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { rmSync } from 'node:fs';
import type { Row } from '@libsql/client';
import { setupTestDb } from './testdb.js';
import { upsertUser } from './auth.js';
import { createMeal } from './meals.js';
import { listMenuImages, deleteFile } from './files.js';
import { execute } from './db.js';
import { newId } from './ids.js';
import { HttpError } from './http.js';

// listMenuImages is the read side of the menu-image feature. Uploads go through
// Vercel Blob (external, not exercised here), so these tests seed uploaded_files
// rows directly and assert the query filters by kind + meal.

let dbFile: string;
let org: Row;
let mealId: string;

before(async () => {
  dbFile = await setupTestDb();
  org = await upsertUser({
    provider: 'google',
    providerUserId: 'org-img',
    displayName: 'Organizer',
    email: 'img@x.com',
  });
  const meal = await createMeal(org, { title: 'Lunch', restaurantName: 'Warung Pak Din' });
  mealId = String(meal.id);
});

after(() => {
  try {
    rmSync(dbFile, { force: true });
  } catch {
    /* ignore */
  }
});

async function seedFile(sessionId: string | null, kind: string, url: string): Promise<string> {
  const id = newId('file');
  await execute(
    `INSERT INTO uploaded_files (id, owner_user_id, meal_session_id, file_kind, blob_url)
     VALUES (?, ?, ?, ?, ?)`,
    [id, String(org.id), sessionId, kind, url],
  );
  return id;
}

test('listMenuImages returns only menu_image files for the meal', async () => {
  await seedFile(mealId, 'menu_image', 'https://blob/menu-1.png');
  await seedFile(mealId, 'menu_image', 'https://blob/menu-2.jpg');
  await seedFile(mealId, 'duitnow_qr', 'https://blob/qr.png'); // different kind — excluded
  await seedFile(null, 'menu_image', 'https://blob/loose.png'); // no meal — excluded

  const imgs = await listMenuImages(mealId);
  assert.equal(imgs.length, 2);
  assert.ok(imgs.every((f) => f.file_kind === 'menu_image'));
  assert.ok(imgs.every((f) => String(f.meal_session_id) === mealId));
});

test('listMenuImages is scoped to a single meal', async () => {
  const other = await createMeal(org, { title: 'Dinner', restaurantName: 'Kedai Kopi' });
  assert.equal((await listMenuImages(String(other.id))).length, 0);
});

// Deletion path used by the UI: MenuImagesEditor → DELETE /files/:id → deleteFile.
// deleteFile removes the Blob object (del(blob_url)) AND the uploaded_files row.
// The blob del is a no-op in tests (no token; wrapped in try/catch), so — as with
// the QR-cleanup tests — we assert on the row disappearing, which proves the file
// stops being referenced/served. Menu images are never shared across records, so a
// plain blob+row delete is correct (no ref-counting needed).

test('deleteFile removes a menu image (blob + row) for its owner', async () => {
  const id = await seedFile(mealId, 'menu_image', 'https://blob.example/del-me.png');
  assert.ok((await listMenuImages(mealId)).some((f) => String(f.id) === id));

  await deleteFile(String(org.id), id);
  assert.ok(
    !(await listMenuImages(mealId)).some((f) => String(f.id) === id),
    'the image row is gone after deleteFile',
  );
});

test('deleteFile is owner-scoped: a non-owner cannot delete the image', async () => {
  const id = await seedFile(mealId, 'menu_image', 'https://blob.example/keep.png');
  const stranger = await upsertUser({ provider: 'google', providerUserId: 'stranger', displayName: 'Nope' });

  await assert.rejects(
    () => deleteFile(String(stranger.id), id),
    (e) => e instanceof HttpError && e.status === 404,
  );
  assert.ok(
    (await listMenuImages(mealId)).some((f) => String(f.id) === id),
    'the image is untouched when a non-owner tries to delete it',
  );
});
