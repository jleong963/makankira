/**
 * reminders.ts — order-submission reminders (README Section 15). Invoked by the
 * free GitHub Actions cron. Sends email (Gmail SMTP) + Web Push (web-push) to the
 * organizer before meal time, once per session. Sends are best-effort; the
 * find-due query is pure and unit-tested.
 */

import type { Row } from '@libsql/client';
import { query, execute } from './db.js';
import { reminderText } from './i18n.js';
import { sendEmail, emailConfigured } from './email.js';
import * as webpush from 'web-push';

/** Sessions whose reminder is due and not yet sent, while still collecting. */
export async function findDueSessions(nowIso: string): Promise<Row[]> {
  return query(
    `SELECT ms.*, u.email AS owner_email, u.preferred_language AS owner_language
       FROM meal_sessions ms
       JOIN users u ON ms.owner_user_id = u.id
      WHERE ms.reminder_enabled = 1
        AND ms.reminder_sent_at IS NULL
        AND ms.remind_at IS NOT NULL
        AND ms.remind_at <= ?
        AND ms.status IN ('draft', 'collecting_orders')
      ORDER BY ms.remind_at`,
    [nowIso],
  );
}

/**
 * Mark a session's reminder as delivered — called when the organizer's own app
 * fires the in-session reminder at remind_at, so the cron doesn't then send a
 * duplicate (push + email). Idempotent and race-safe: only stamps the time when
 * it's still null, so it never clobbers (or double-counts against) a real cron
 * send that may already have happened.
 */
export async function markReminderSent(mealId: string, nowIso: string): Promise<void> {
  await execute(
    'UPDATE meal_sessions SET reminder_sent_at = ? WHERE id = ? AND reminder_sent_at IS NULL',
    [nowIso, mealId],
  );
}

/** Outcome of one reminder run — logged and returned so a single cron run tells
 *  you exactly what went out (and why nothing did). Surfaced as the JSON body of
 *  POST /api/cron/reminders, which the GitHub Actions log prints verbatim. */
export interface ReminderRunSummary {
  processed: number; // due sessions handled this run
  emailConfigured: boolean; // Gmail SMTP creds present
  pushConfigured: boolean; // VAPID keys present
  emailsSent: number;
  emailsFailed: number;
  pushSubscriptions: number; // total devices we attempted to push to
  pushSent: number;
  pushFailed: number;
}

interface PushResult {
  subscriptions: number;
  sent: number;
  failed: number;
}

async function sendPush(userId: string, title: string, body: string): Promise<PushResult> {
  const pub = process.env.VAPID_PUBLIC_KEY;
  const priv = process.env.VAPID_PRIVATE_KEY;
  if (!pub || !priv) return { subscriptions: 0, sent: 0, failed: 0 };
  try {
    webpush.setVapidDetails(process.env.VAPID_SUBJECT ?? 'mailto:reminders@makankira.app', pub, priv);
  } catch (e) {
    console.error('vapid setup failed:', e);
    return { subscriptions: 0, sent: 0, failed: 0 };
  }
  const subs = await query('SELECT endpoint, p256dh, auth FROM push_subscriptions WHERE user_id = ?', [userId]);
  const payload = JSON.stringify({ title, body });
  let sent = 0;
  let failed = 0;
  for (const s of subs) {
    try {
      await webpush.sendNotification(
        { endpoint: String(s.endpoint), keys: { p256dh: String(s.p256dh), auth: String(s.auth) } },
        payload,
      );
      sent++;
    } catch (e) {
      failed++;
      console.error('push send failed:', e);
    }
  }
  return { subscriptions: subs.length, sent, failed };
}

export async function sendReminders(nowIso: string): Promise<ReminderRunSummary> {
  const due = await findDueSessions(nowIso);
  const emailOn = emailConfigured();
  const pushConfigured = Boolean(process.env.VAPID_PUBLIC_KEY && process.env.VAPID_PRIVATE_KEY);
  const summary: ReminderRunSummary = {
    processed: due.length,
    emailConfigured: emailOn,
    pushConfigured,
    emailsSent: 0,
    emailsFailed: 0,
    pushSubscriptions: 0,
    pushSent: 0,
    pushFailed: 0,
  };

  for (const m of due) {
    const { subject, body } = reminderText(String(m.owner_language ?? 'en'), String(m.title));

    let emailStatus: 'sent' | 'failed' | 'skipped' | 'none' = 'none';
    if (m.owner_email) {
      const ok = await sendEmail(String(m.owner_email), subject, body);
      if (ok) {
        summary.emailsSent++;
        emailStatus = 'sent';
      } else if (emailOn) {
        summary.emailsFailed++;
        emailStatus = 'failed';
      } else {
        emailStatus = 'skipped'; // Gmail SMTP not configured — email channel off
      }
    }

    const push = await sendPush(String(m.owner_user_id), subject, body);
    summary.pushSubscriptions += push.subscriptions;
    summary.pushSent += push.sent;
    summary.pushFailed += push.failed;

    await execute('UPDATE meal_sessions SET reminder_sent_at = ? WHERE id = ?', [nowIso, String(m.id)]);

    // Per-session line in the Vercel function log — lets you see delivery for a
    // specific meal (e.g. pushSubscriptions:0 means the organizer never enabled
    // Web Push on any device, so no toast could ever arrive).
    console.log(
      '[reminders]',
      JSON.stringify({
        sessionId: String(m.id),
        title: String(m.title),
        ownerUserId: String(m.owner_user_id),
        email: emailStatus,
        pushSubscriptions: push.subscriptions,
        pushSent: push.sent,
        pushFailed: push.failed,
      }),
    );
  }

  console.log('[reminders] run summary', JSON.stringify(summary));
  return summary;
}
