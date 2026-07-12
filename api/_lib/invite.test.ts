import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { rmSync } from 'node:fs';
import type { Row } from '@libsql/client';
import { setupTestDb } from './testdb.js';
import { query, execute, queryOne } from './db.js';
import { upsertUser } from './auth.js';
import { createMeal } from './meals.js';
import { addMenuItem } from './menu.js';
import { getMyOrder, upsertMyOrder } from './orders.js';
import { joinByToken, leaveMeal, listJoinedMeals, memberContext, rotateInviteToken } from './membership.js';

let dbFile: string;
let organizer: Row;
let participant: Row;
let stranger: Row;
let mealId: string;
let itemId: string;
let token: string;

before(async () => {
  dbFile = await setupTestDb();
  organizer = await upsertUser({ provider: 'google', providerUserId: 'inv-org', displayName: 'Org', email: 'org@x.com' });
  participant = await upsertUser({ provider: 'google', providerUserId: 'inv-p1', displayName: 'Pat', email: 'pat@x.com' });
  stranger = await upsertUser({ provider: 'google', providerUserId: 'inv-p2', displayName: 'Stan', email: 'stan@x.com' });
  const meal = await createMeal(organizer, { title: 'Team Lunch', restaurantName: 'ABC' });
  mealId = String(meal.id);
  token = String(meal.invite_token);
  const item = await addMenuItem(mealId, { name: 'Nasi Lemak', estimatedPriceCents: 500 });
  itemId = String(item.id);
  await execute("UPDATE meal_sessions SET status = 'collecting_orders' WHERE id = ?", [mealId]);
});

after(() => {
  try {
    rmSync(dbFile, { force: true });
  } catch {
    /* ignore */
  }
});

test('createMeal issues an invite token', () => {
  assert.match(token, /^inv_/);
});

test('joining by token records membership; a bad token is rejected', async () => {
  await joinByToken(String(participant.id), token);
  const row = await queryOne('SELECT 1 FROM meal_participants WHERE meal_session_id = ? AND user_id = ?', [mealId, String(participant.id)]);
  assert.ok(row, 'membership row created');
  await joinByToken(String(participant.id), token); // idempotent, no duplicate
  await assert.rejects(() => joinByToken(String(stranger.id), 'inv_bogus'), /not valid/i);
});

test('memberContext: owner and joined member pass; a stranger is forbidden', async () => {
  assert.equal((await memberContext(String(organizer.id), mealId)).isOwner, true);
  assert.equal((await memberContext(String(participant.id), mealId)).isOwner, false);
  await assert.rejects(() => memberContext(String(stranger.id), mealId), /not joined/i);
});

test('a participant manages only their own order (create then update, never duplicated)', async () => {
  const created = await upsertMyOrder(mealId, String(participant.id), {
    participantName: 'Pat',
    mobileNumber: '0123456789',
    items: [{ menuItemId: itemId, quantity: 1 }],
  });
  assert.equal(String(created.order.participant_user_id), String(participant.id));
  const updated = await upsertMyOrder(mealId, String(participant.id), {
    participantName: 'Pat',
    mobileNumber: '0123456789',
    items: [{ menuItemId: itemId, quantity: 3 }],
  });
  assert.equal(String(updated.order.id), String(created.order.id), 'same order updated, not a second one');
  assert.equal(Number((await getMyOrder(mealId, String(participant.id)))!.items[0]!.quantity), 3);
});

test('listJoinedMeals returns joined (non-owned) meals only', async () => {
  const forParticipant = await listJoinedMeals(String(participant.id));
  assert.ok(forParticipant.some((m) => String(m.id) === mealId), 'participant sees the joined meal');
  const forOwner = await listJoinedMeals(String(organizer.id));
  assert.ok(!forOwner.some((m) => String(m.id) === mealId), 'owner never sees their own meal as "joined"');
});

test('leaving removes membership but keeps the order', async () => {
  await leaveMeal(String(participant.id), mealId);
  const membership = await queryOne('SELECT 1 FROM meal_participants WHERE meal_session_id = ? AND user_id = ?', [mealId, String(participant.id)]);
  assert.equal(membership, null, 'membership removed');
  assert.ok(await getMyOrder(mealId, String(participant.id)), 'order kept after leaving');
});

test('rotating the token invalidates the old link and issues a working new one', async () => {
  const fresh = await rotateInviteToken(mealId);
  assert.notEqual(fresh, token);
  await assert.rejects(() => joinByToken(String(stranger.id), token), /not valid/i);
  await joinByToken(String(stranger.id), fresh);
  assert.ok(await queryOne('SELECT 1 FROM meal_participants WHERE meal_session_id = ? AND user_id = ?', [mealId, String(stranger.id)]));
});

test('participant ordering is locked once the meal is finalized', async () => {
  await execute("UPDATE meal_sessions SET status = 'finalized' WHERE id = ?", [mealId]);
  await assert.rejects(
    () =>
      upsertMyOrder(mealId, String(stranger.id), {
        participantName: 'Stan',
        mobileNumber: '0123456789',
        items: [{ menuItemId: itemId, quantity: 1 }],
      }),
    /locked/i,
  );
});

test('inline new item: created with the order in one atomic save (name + estimate only)', async () => {
  await execute("UPDATE meal_sessions SET status = 'collecting_orders' WHERE id = ?", [mealId]);
  const before = (await query('SELECT id FROM menu_items WHERE meal_session_id = ?', [mealId])).length;

  // actual_price_cents is supplied but must be ignored — only the organizer sets it.
  const { items } = await upsertMyOrder(mealId, String(participant.id), {
    participantName: 'Pat',
    mobileNumber: '0123456789',
    items: [
      { menuItemId: itemId, quantity: 1 },
      { newItem: { name: 'Teh Tarik', estimatedPriceCents: 250, actualPriceCents: 999 }, quantity: 2, remarks: 'less sweet' },
    ],
  });

  const menu = await query('SELECT * FROM menu_items WHERE meal_session_id = ?', [mealId]);
  assert.equal(menu.length, before + 1, 'exactly one new menu item created');
  const teh = menu.find((m) => String(m.name) === 'Teh Tarik')!;
  assert.ok(teh, 'inline item joined the shared menu');
  assert.equal(Number(teh.estimated_price_cents), 250);
  assert.equal(teh.actual_price_cents, null, 'participant cannot set the actual price');
  assert.equal(Number(teh.available), 1, 'available to everyone');
  assert.ok(
    items.some((it) => String(it.menu_item_id) === String(teh.id) && Number(it.quantity) === 2),
    'the order references the new item',
  );

  // Atomicity: a bad entry alongside a new item writes nothing — no orphan.
  const beforeBad = (await query('SELECT id FROM menu_items WHERE meal_session_id = ?', [mealId])).length;
  await assert.rejects(
    () =>
      upsertMyOrder(mealId, String(participant.id), {
        participantName: 'Pat',
        mobileNumber: '0123456789',
        items: [
          { newItem: { name: 'Should Not Persist' }, quantity: 1 },
          { menuItemId: 'does-not-exist', quantity: 1 },
        ],
      }),
    /Unknown menu item/i,
  );
  const afterBad = (await query('SELECT id FROM menu_items WHERE meal_session_id = ?', [mealId])).length;
  assert.equal(afterBad, beforeBad, 'a failed save creates no menu item');

  // Menu additions are still blocked once the session is finalized.
  await execute("UPDATE meal_sessions SET status = 'finalized' WHERE id = ?", [mealId]);
  await assert.rejects(
    () =>
      upsertMyOrder(mealId, String(participant.id), {
        participantName: 'Pat',
        mobileNumber: '0123456789',
        items: [{ newItem: { name: 'Too Late' }, quantity: 1 }],
      }),
    /locked/i,
  );
});
