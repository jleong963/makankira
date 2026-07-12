import { test, before, after } from 'node:test';
import assert from 'node:assert/strict';
import { rmSync } from 'node:fs';
import type { Row } from '@libsql/client';
import { setupTestDb } from './testdb.js';
import { upsertUser } from './auth.js';
import { createMeal } from './meals.js';
import { addMenuItem } from './menu.js';
import { createOrder, upsertMyOrder } from './orders.js';
import { addMethod, mealScope } from './paymentMethods.js';
import { upsertBill } from './bill.js';
import { runCalculation } from './calculate.js';
import { listResults, getResult, getMyResult, markPaid, markPending, overrideResult, listEvents } from './payments.js';
import { buildRequests } from './paymentRequests.js';

let dbFile: string;
let org: Row;
let mealId: string;
let aliceResultId: string;

before(async () => {
  dbFile = await setupTestDb();
  org = await upsertUser({ provider: 'google', providerUserId: 'pay-org', displayName: 'Org' });
  const meal = await createMeal(org, { title: 'Team Lunch', restaurantName: 'ABC' });
  mealId = String(meal.id);
  await addMethod(mealScope(mealId), { methodType: 'duitnow_id', duitNowId: '0123456789' });
  const chicken = await addMenuItem(mealId, { name: 'Chicken Rice', actualPriceCents: 1000 });
  await createOrder(mealId, {
    participantName: 'Alice',
    mobileNumber: '0123456789',
    items: [{ menuItemId: chicken.id, quantity: 1 }],
  });
  await upsertBill(mealId, { calculationMode: 'item_based', finalBillAmountCents: 1000 });
  await runCalculation(mealId);
  aliceResultId = String((await listResults(mealId))[0]!.id);
});

after(() => {
  try {
    rmSync(dbFile, { force: true });
  } catch {
    /* ignore */
  }
});

test('mark-paid then mark-pending update status and log events', async () => {
  const paid = await markPaid(mealId, aliceResultId, null, String(org.id));
  assert.equal(paid.payment_status, 'paid');
  assert.ok(paid.paid_at, 'paid_at set');

  const pending = await markPending(mealId, aliceResultId, String(org.id));
  assert.equal(pending.payment_status, 'pending');
  assert.equal(pending.paid_at, null);

  const events = await listEvents(mealId);
  const types = events.map((e) => String(e.event_type));
  assert.ok(types.includes('marked_paid'));
  assert.ok(types.includes('marked_pending'));
});

test('override sets is_manual_override and logs the new amount', async () => {
  const overridden = await overrideResult(mealId, aliceResultId, { totalDueCents: 777, note: 'goodwill' }, String(org.id));
  assert.equal(Number(overridden.total_due_cents), 777);
  assert.equal(Number(overridden.is_manual_override), 1);

  const event = (await listEvents(mealId)).find((e) => e.event_type === 'amount_overridden');
  assert.ok(event);
  assert.equal(Number(event!.amount_cents), 777);
  assert.equal(String(event!.note), 'goodwill');
});

test('payment request: message, wa.me link, and method details', async () => {
  // reset Alice to a clean computed state for a predictable message
  await runCalculation(mealId);
  const result = await getResult(mealId, aliceResultId);
  // override test set is_manual_override; runCalculation preserves it — clear for this check
  if (Number(result.is_manual_override) === 1) {
    await overrideResult(mealId, aliceResultId, { totalDueCents: 1000 }, String(org.id));
  }

  const reqs = await buildRequests(mealId, 'en');
  assert.equal(reqs.length, 1);
  const r = reqs[0]!;
  assert.equal(r.participantName, 'Alice');
  assert.match(r.message, /Alice/);
  assert.match(r.message, /RM 10\.00/);
  assert.match(r.message, /DuitNow ID: 0123456789/);
  assert.equal(r.whatsappUrl, `https://wa.me/60123456789?text=${encodeURIComponent(r.message)}`);
});

test('payment request greeting is localized', async () => {
  const ms = (await buildRequests(mealId, 'ms'))[0]!;
  assert.match(ms.message, /^Hai Alice/);
  const zh = (await buildRequests(mealId, 'zh'))[0]!;
  assert.match(zh.message, /Alice 您好/);
});

test('getMyResult returns only the caller\'s own result, and null for a non-participant', async () => {
  // Separate meal so this doesn't perturb the shared Alice fixture above.
  const participant = await upsertUser({ provider: 'google', providerUserId: 'pay-part', displayName: 'Bob' });
  const stranger = await upsertUser({ provider: 'google', providerUserId: 'pay-stranger', displayName: 'Eve' });
  const meal = await createMeal(org, { title: 'Solo Lunch', restaurantName: 'XYZ' });
  const mid = String(meal.id);
  const nasi = await addMenuItem(mid, { name: 'Nasi Lemak', actualPriceCents: 800 });
  // Bob submits his OWN order (sets participant_user_id — the link getMyResult uses).
  await upsertMyOrder(mid, String(participant.id), {
    participantName: 'Bob',
    mobileNumber: '0198887777',
    items: [{ menuItemId: nasi.id, quantity: 1 }],
  });
  await upsertBill(mid, { calculationMode: 'item_based', finalBillAmountCents: 800 });
  await runCalculation(mid);

  const mine = await getMyResult(mid, String(participant.id));
  assert.ok(mine, 'Bob has a result');
  assert.equal(Number(mine!.total_due_cents), 800);
  assert.equal(String(mine!.participant_name), 'Bob');

  // Someone who never joined/ordered gets nothing — no cross-participant leak.
  assert.equal(await getMyResult(mid, String(stranger.id)), null);
});

test('WhatsApp link survives the country-code picker: E.164 input → clean wa.me digits', async () => {
  // Separate meal so the shared Alice fixture is untouched.
  const meal = await createMeal(org, { title: 'Intl Lunch', restaurantName: 'SG Cafe' });
  const mid = String(meal.id);
  const laksa = await addMenuItem(mid, { name: 'Laksa', actualPriceCents: 1200 });
  // The PhoneField submits a composed international number with a leading '+'.
  await createOrder(mid, {
    participantName: 'Wei',
    mobileNumber: '+65 9123 4567', // Singapore, with spaces as a picker might send
    items: [{ menuItemId: laksa.id, quantity: 1 }],
  });
  await upsertBill(mid, { calculationMode: 'item_based', finalBillAmountCents: 1200 });
  await runCalculation(mid);

  const reqs = await buildRequests(mid, 'en');
  assert.equal(reqs.length, 1);
  const r = reqs[0]!;
  // Stored/served as pure digits (no '+', no spaces) — exactly what wa.me needs.
  assert.equal(r.mobileNumber, '6591234567');
  assert.equal(r.whatsappUrl, `https://wa.me/6591234567?text=${encodeURIComponent(r.message)}`);

  // And a legacy Malaysian entry (no picker) still produces the 60… wa.me link.
  const meal2 = await createMeal(org, { title: 'KL Lunch', restaurantName: 'Mamak' });
  const mid2 = String(meal2.id);
  const teh = await addMenuItem(mid2, { name: 'Teh', actualPriceCents: 200 });
  await createOrder(mid2, { participantName: 'Siti', mobileNumber: '0123456789', items: [{ menuItemId: teh.id, quantity: 1 }] });
  await upsertBill(mid2, { calculationMode: 'item_based', finalBillAmountCents: 200 });
  await runCalculation(mid2);
  const r2 = (await buildRequests(mid2, 'en'))[0]!;
  assert.equal(r2.whatsappUrl, `https://wa.me/60123456789?text=${encodeURIComponent(r2.message)}`);
});
