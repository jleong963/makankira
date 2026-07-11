/**
 * membership.ts — participant access to meals via invite links (README Phase 4).
 *
 * Access model: a meal has an unguessable `invite_token`. A logged-in user who
 * opens the link JOINS the meal (a meal_participants row), which then grants them
 * return access from their own dashboard without the link. Membership is separate
 * from ownership: joining never lets a participant see other meals, and a meal is
 * never listed for a user who hasn't joined (or doesn't own) it.
 *
 * The token is only the capability to *first* join; ongoing access is by
 * membership, so rotating the token blocks new joins without kicking members.
 */

import type { VercelRequest } from '@vercel/node';
import type { Row } from '@libsql/client';
import { query, queryOne, execute } from './db.js';
import { newId, newInviteToken } from './ids.js';
import { HttpError } from './http.js';
import { requireUser } from './auth.js';
import { getMeal } from './meals.js';

/** Resolve an invite token to its meal, and record the user's membership. */
export async function joinByToken(userId: string, token: string): Promise<Row> {
  const meal = token
    ? await queryOne('SELECT * FROM meal_sessions WHERE invite_token = ?', [token])
    : null;
  if (!meal) throw new HttpError(404, 'invalid_invite', 'This invite link is not valid');
  // The owner already has full access; they don't need a membership row.
  if (String(meal.owner_user_id) !== userId) {
    await execute(
      `INSERT INTO meal_participants (id, meal_session_id, user_id)
       VALUES (?, ?, ?)
       ON CONFLICT (meal_session_id, user_id) DO NOTHING`,
      [newId('mp'), String(meal.id), userId],
    );
  }
  return meal;
}

/** Remove only the membership (the participant's order is intentionally kept). */
export async function leaveMeal(userId: string, mealId: string): Promise<void> {
  await execute('DELETE FROM meal_participants WHERE meal_session_id = ? AND user_id = ?', [mealId, userId]);
}

/** Meals this user has joined but does not own (their "joined" dashboard list). */
export async function listJoinedMeals(userId: string): Promise<Row[]> {
  return query(
    `SELECT ms.* FROM meal_sessions ms
       JOIN meal_participants mp ON mp.meal_session_id = ms.id
      WHERE mp.user_id = ? AND ms.owner_user_id != ?
      ORDER BY mp.joined_at DESC`,
    [userId, userId],
  );
}

/** Backfill an invite token for meals created before this feature; returns it. */
export async function ensureInviteToken(meal: Row): Promise<string> {
  if (meal.invite_token) return String(meal.invite_token);
  const token = newInviteToken();
  await execute('UPDATE meal_sessions SET invite_token = ? WHERE id = ?', [token, String(meal.id)]);
  return token;
}

/** Replace the invite token, invalidating any previously shared link. */
export async function rotateInviteToken(mealId: string): Promise<string> {
  const token = newInviteToken();
  await execute('UPDATE meal_sessions SET invite_token = ? WHERE id = ?', [token, mealId]);
  return token;
}

/** Core check (testable without a request): owner OR joined participant. */
export async function memberContext(userId: string, mealId: string): Promise<{ meal: Row; isOwner: boolean }> {
  const meal = await getMeal(mealId);
  if (!meal) throw new HttpError(404, 'not_found', 'Meal session not found');
  const isOwner = String(meal.owner_user_id) === userId;
  if (!isOwner) {
    const m = await queryOne(
      'SELECT 1 FROM meal_participants WHERE meal_session_id = ? AND user_id = ?',
      [mealId, userId],
    );
    if (!m) throw new HttpError(403, 'forbidden', 'You have not joined this meal');
  }
  return { meal, isOwner };
}

/** Handler helper: authenticate, then require owner-or-member access. */
export async function requireMember(
  req: VercelRequest,
  mealId: string,
): Promise<{ user: Row; meal: Row; isOwner: boolean }> {
  const user = await requireUser(req);
  const ctx = await memberContext(String(user.id), mealId);
  return { user, ...ctx };
}
