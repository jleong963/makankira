import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { rmSync } from 'node:fs';
import type { Row } from '@libsql/client';
import { setupTestDb } from './testdb.js';
import { execute } from './db.js';
import { upsertUser } from './auth.js';
import { createMeal, updateMeal, getMeal } from './meals.js';
import { findDueSessions, sendReminders, markReminderSent } from './reminders.js';

let dbFile: string;
let org: Row;

before(async () => {
  dbFile = await setupTestDb();
  org = await upsertUser({ provider: 'google', providerUserId: 'rem-org', displayName: 'Org', email: 'o@x.com' });
});
after(() => {
  try {
    rmSync(dbFile, { force: true });
  } catch {
    /* ignore */
  }
});

test('findDueSessions returns only due, unsent, still-collecting sessions', async () => {
  const due = await createMeal(org, { title: 'Due', restaurantName: 'R' });
  const future = await createMeal(org, { title: 'Future', restaurantName: 'R' });
  const sent = await createMeal(org, { title: 'Sent', restaurantName: 'R' });
  const finalized = await createMeal(org, { title: 'Finalized', restaurantName: 'R' });

  await execute("UPDATE meal_sessions SET remind_at = '2026-06-27T00:00:00Z', status = 'collecting_orders' WHERE id = ?", [String(due.id)]);
  await execute("UPDATE meal_sessions SET remind_at = '2030-01-01T00:00:00Z', status = 'collecting_orders' WHERE id = ?", [String(future.id)]);
  await execute("UPDATE meal_sessions SET remind_at = '2026-06-27T00:00:00Z', reminder_sent_at = '2026-06-27T01:00:00Z' WHERE id = ?", [String(sent.id)]);
  await execute("UPDATE meal_sessions SET remind_at = '2026-06-27T00:00:00Z', status = 'finalized' WHERE id = ?", [String(finalized.id)]);

  const ids = (await findDueSessions('2026-06-28T00:00:00Z')).map((r) => String(r.id));
  assert.ok(ids.includes(String(due.id)), 'due session found');
  assert.ok(!ids.includes(String(future.id)), 'future excluded');
  assert.ok(!ids.includes(String(sent.id)), 'already-sent excluded');
  assert.ok(!ids.includes(String(finalized.id)), 'finalized excluded');
});

test('updateMeal does not resurrect an already-sent reminder on an unrelated edit', async () => {
  const m = await createMeal(org, { title: 'ReArm', restaurantName: 'R' });
  // Simulate a reminder that already fired: past remind_at + a sent marker.
  await execute(
    "UPDATE meal_sessions SET status='collecting_orders', remind_at='2026-06-27T00:00:00Z', reminder_sent_at='2026-06-27T01:00:00Z' WHERE id=?",
    [String(m.id)],
  );

  // The app always includes reminderEnabled on save; an unrelated field edit must
  // NOT clear the sent marker (that was the duplicate-notification bug).
  const updated = await updateMeal(String(org.id), String(m.id), { reminderEnabled: true, title: 'ReArm 2' });
  assert.equal(updated.reminder_sent_at, '2026-06-27T01:00:00Z', 'sent marker preserved');
  assert.equal(updated.remind_at, '2026-06-27T00:00:00Z', 'remind_at unchanged');

  const dueIds = (await findDueSessions('2026-06-28T00:00:00Z')).map((r) => String(r.id));
  assert.ok(!dueIds.includes(String(m.id)), 'not re-fired after an unrelated edit');
});

test('updateMeal re-arms when the reminder is rescheduled to a new future time', async () => {
  const m = await createMeal(org, { title: 'Resched', restaurantName: 'R' });
  await execute(
    "UPDATE meal_sessions SET status='collecting_orders', remind_at='2026-06-27T00:00:00Z', reminder_sent_at='2026-06-27T01:00:00Z' WHERE id=?",
    [String(m.id)],
  );

  const updated = await updateMeal(String(org.id), String(m.id), {
    reminderEnabled: true,
    remindAt: '2999-01-01T00:00:00Z',
  });
  assert.equal(updated.reminder_sent_at, null, 'sent marker cleared on reschedule');
  assert.equal(updated.remind_at, '2999-01-01T00:00:00Z', 'new remind_at stored');
});

test('sendReminders marks a due session sent exactly once', async () => {
  const m = await createMeal(org, { title: 'Send', restaurantName: 'R' });
  await execute(
    "UPDATE meal_sessions SET status='collecting_orders', remind_at='2026-06-27T00:00:00Z' WHERE id=?",
    [String(m.id)],
  );

  // No GMAIL/VAPID env in tests, so email + push are best-effort no-ops; the run
  // still records the session and stamps reminder_sent_at.
  const first = await sendReminders('2026-06-28T00:00:00Z');
  assert.ok(first.processed >= 1, 'processed the due session');
  assert.equal(
    String((await getMeal(String(m.id)))!.reminder_sent_at),
    '2026-06-28T00:00:00Z',
    'marked sent',
  );

  // A later run must not re-send it — dedup holds.
  const before = String((await getMeal(String(m.id)))!.reminder_sent_at);
  await sendReminders('2026-06-29T00:00:00Z');
  const after = String((await getMeal(String(m.id)))!.reminder_sent_at);
  assert.equal(after, before, 'not re-sent on a later run');
});

test('markReminderSent suppresses the cron (in-session de-dup) and is idempotent', async () => {
  const m = await createMeal(org, { title: 'InSession', restaurantName: 'R' });
  await execute(
    "UPDATE meal_sessions SET status='collecting_orders', remind_at='2026-06-27T00:00:00Z' WHERE id=?",
    [String(m.id)],
  );

  // The organizer's app fired the reminder in-session and marked it.
  await markReminderSent(String(m.id), '2026-06-27T00:00:00Z');
  const dueIds = (await findDueSessions('2026-06-28T00:00:00Z')).map((r) => String(r.id));
  assert.ok(!dueIds.includes(String(m.id)), 'cron no longer treats it as due');

  // A second mark must not overwrite the first timestamp (never clobbers a send).
  await markReminderSent(String(m.id), '2026-06-30T00:00:00Z');
  assert.equal(
    String((await getMeal(String(m.id)))!.reminder_sent_at),
    '2026-06-27T00:00:00Z',
    'timestamp preserved (idempotent)',
  );
});
