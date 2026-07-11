/**
 * ids.ts — application-generated primary keys: a type prefix + a short unique id
 * (README Section 16, "IDs are TEXT, application-generated with a type prefix").
 */

import { customAlphabet } from 'nanoid';

// URL-safe, lowercase, no ambiguous separators inside the random part.
const nano = customAlphabet('0123456789abcdefghijklmnopqrstuvwxyz', 20);

export type IdPrefix =
  | 'user'
  | 'meal'
  | 'item'
  | 'order'
  | 'oi'
  | 'bill'
  | 'pm'
  | 'upm'
  | 'file'
  | 'pr'
  | 'evt'
  | 'push'
  | 'mp'; // meal_participants

export function newId(prefix: IdPrefix): string {
  return `${prefix}_${nano()}`;
}

// Invite token — a shareable capability (goes in a URL), so it uses more
// entropy than a row id: 32 chars of a 36-symbol alphabet ≈ 165 bits.
const nanoToken = customAlphabet('0123456789abcdefghijklmnopqrstuvwxyz', 32);

export function newInviteToken(): string {
  return `inv_${nanoToken()}`;
}
