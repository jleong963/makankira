/**
 * validate.ts — small shared validators (README Section 11).
 */

import { HttpError } from './http.js';

export type Locale = 'en' | 'zh' | 'ms';

/** A non-negative integer amount in sen, or null when absent. */
export function optionalIntCents(v: unknown, field: string): number | null {
  if (v == null) return null;
  if (typeof v === 'number' && Number.isInteger(v) && v >= 0) return v;
  throw new HttpError(400, 'invalid_amount', `${field} must be a non-negative integer (sen)`);
}

/** A required non-negative integer amount in sen. */
export function requireIntCents(v: unknown, field: string): number {
  const n = optionalIntCents(v, field);
  if (n == null) throw new HttpError(400, 'invalid_amount', `${field} is required`);
  return n;
}

/** A positive integer quantity. */
export function requirePositiveInt(v: unknown, field: string): number {
  if (typeof v === 'number' && Number.isInteger(v) && v > 0) return v;
  throw new HttpError(400, 'invalid_quantity', `${field} must be a positive integer`);
}

export function isSupportedLocale(v: unknown): v is Locale {
  return v === 'en' || v === 'zh' || v === 'ms';
}

/**
 * Normalize a mobile number to digits-only (no `+`), suitable for wa.me links.
 * Accepts an international E.164 number from the country-code picker
 * (`+<8–15 digits>`), and — for backward compatibility — bare Malaysian input
 * (`0123456789`, `60123456789`, `+60123456789`) which is normalized to `60…`.
 * Spaces/dashes are ignored. Returns null if it doesn't look like a phone number.
 */
export function normalizeMobile(raw: string): string | null {
  const s = raw.replace(/[\s-]/g, '');
  // International E.164 from the country-code picker: "+" then 8–15 digits.
  if (/^\+\d{8,15}$/.test(s)) return s.slice(1);
  // Legacy Malaysian input (no country-code picker): "0…"/"60…"/"+60…" mobile.
  if (/^(?:\+?60|0)1\d{7,9}$/.test(s)) {
    const digits = s.replace(/^\+/, '');
    return digits.startsWith('0') ? '60' + digits.slice(1) : digits;
  }
  return null;
}
