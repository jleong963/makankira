/**
 * payments.ts — reads over computed payment_results (README Screens 8, 9).
 * Mutations (override, mark paid/pending) + the status-event log are added next.
 */

import type { Row } from '@libsql/client';
import { query } from './db';

export async function listResults(mealId: string): Promise<Row[]> {
  return query('SELECT * FROM payment_results WHERE meal_session_id = ? ORDER BY created_at', [mealId]);
}
