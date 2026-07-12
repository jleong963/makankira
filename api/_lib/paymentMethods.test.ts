import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { rmSync } from 'node:fs';
import type { Row } from '@libsql/client';
import { setupTestDb } from './testdb.js';
import { execute, queryOne } from './db.js';
import { upsertUser } from './auth.js';
import { createMeal, deleteMeal } from './meals.js';
import { addMethod, updateMethod, deleteMethod, userScope, mealScope } from './paymentMethods.js';

let dbFile: string;
let user: Row;

before(async () => {
  dbFile = await setupTestDb();
  user = await upsertUser({ provider: 'google', providerUserId: 'pm-user', displayName: 'Owner' });
});

after(() => {
  try {
    rmSync(dbFile, { force: true });
  } catch {
    /* ignore */
  }
});

// Simulate an uploaded QR file row (real uploads need a Blob token; the blob
// del is a no-op here, but the DB row deletion is what we assert on).
async function seedFile(id: string): Promise<void> {
  await execute(
    "INSERT INTO uploaded_files (id, owner_user_id, file_kind, blob_url) VALUES (?, ?, 'duitnow_qr', ?)",
    [id, String(user.id), `https://blob.example/${id}`],
  );
}

const fileExists = async (id: string): Promise<boolean> =>
  (await queryOne('SELECT 1 FROM uploaded_files WHERE id = ?', [id])) != null;

test('deleting a DuitNow-QR method removes its (orphaned) blob file', async () => {
  await seedFile('file_solo');
  const m = await addMethod(userScope(String(user.id)), { methodType: 'duitnow_qr', qrImageFileId: 'file_solo' });
  assert.equal(await fileExists('file_solo'), true);

  await deleteMethod(userScope(String(user.id)), String(m.id));
  assert.equal(await fileExists('file_solo'), false, 'QR file removed together with the method');
});

test('a shared QR file is kept until the LAST method referencing it is deleted', async () => {
  // Create the meal before any account default so prefill copies nothing; then
  // point both an account method and a session method at the same file (as the
  // prefill-on-create path would).
  const meal = await createMeal(user, { title: 'Team Lunch', restaurantName: 'ABC' });
  await seedFile('file_shared');
  const acct = await addMethod(userScope(String(user.id)), { methodType: 'duitnow_qr', qrImageFileId: 'file_shared' });
  const sess = await addMethod(mealScope(String(meal.id)), { methodType: 'duitnow_qr', qrImageFileId: 'file_shared' });

  await deleteMethod(userScope(String(user.id)), String(acct.id));
  assert.equal(await fileExists('file_shared'), true, 'kept — the session method still references it');

  await deleteMethod(mealScope(String(meal.id)), String(sess.id));
  assert.equal(await fileExists('file_shared'), false, 'removed — last reference gone');
});

test('swapping a QR image deletes the replaced file once orphaned', async () => {
  await seedFile('file_old');
  await seedFile('file_new');
  const m = await addMethod(userScope(String(user.id)), { methodType: 'duitnow_qr', qrImageFileId: 'file_old' });

  await updateMethod(userScope(String(user.id)), String(m.id), { qrImageFileId: 'file_new' });
  assert.equal(await fileExists('file_old'), false, 'replaced image removed');
  assert.equal(await fileExists('file_new'), true, 'new image kept');
});

test('deleting a whole meal cleans up its orphaned session QR file', async () => {
  await seedFile('file_meal_qr');
  const meal = await createMeal(user, { title: 'QR Meal', restaurantName: 'R' });
  await addMethod(mealScope(String(meal.id)), { methodType: 'duitnow_qr', qrImageFileId: 'file_meal_qr' });

  await deleteMeal(String(user.id), String(meal.id));
  assert.equal(await fileExists('file_meal_qr'), false, 'session QR blob/file removed with the meal');
});

test('deleting a meal keeps a QR still shared with the account default', async () => {
  await seedFile('file_meal_shared');
  // Account default first, so creating the meal prefills a session copy pointing
  // at the same file.
  const acct = await addMethod(userScope(String(user.id)), { methodType: 'duitnow_qr', qrImageFileId: 'file_meal_shared' });
  const meal = await createMeal(user, { title: 'Shared Meal', restaurantName: 'R' });

  await deleteMeal(String(user.id), String(meal.id));
  assert.equal(await fileExists('file_meal_shared'), true, 'kept — the account default still references it');

  // Cleanup: removing the default now drops the last reference.
  await deleteMethod(userScope(String(user.id)), String(acct.id));
  assert.equal(await fileExists('file_meal_shared'), false, 'removed once the default is gone too');
});

test('deleting a meal reaps its meal-owned (non-QR) uploads too, e.g. a menu image', async () => {
  const meal = await createMeal(user, { title: 'Image Meal', restaurantName: 'R' });
  // A file tied to the meal itself (meal_session_id set), unlike QR files.
  await execute(
    "INSERT INTO uploaded_files (id, owner_user_id, meal_session_id, file_kind, blob_url) VALUES ('file_menu_img', ?, ?, 'menu_image', 'https://blob.example/menu')",
    [String(user.id), String(meal.id)],
  );
  assert.equal(await fileExists('file_menu_img'), true);

  await deleteMeal(String(user.id), String(meal.id));
  assert.equal(await fileExists('file_menu_img'), false, 'meal-owned upload removed with the meal');
});
