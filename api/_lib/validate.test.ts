import { test } from 'node:test';
import assert from 'node:assert/strict';
import { normalizeMobile } from './validate.js';

test('normalizeMobile: international E.164 from the picker keeps the country code', () => {
  assert.equal(normalizeMobile('+60123456789'), '60123456789'); // Malaysia
  assert.equal(normalizeMobile('+6591234567'), '6591234567'); // Singapore
  assert.equal(normalizeMobile('+1 202 555 0123'), '12025550123'); // US, spaces stripped
  assert.equal(normalizeMobile('+44-7700-900123'), '447700900123'); // UK, dashes stripped
});

test('normalizeMobile: legacy Malaysian input still normalizes to 60…', () => {
  assert.equal(normalizeMobile('0123456789'), '60123456789');
  assert.equal(normalizeMobile('60123456789'), '60123456789');
});

test('normalizeMobile: rejects non-numbers and out-of-range lengths', () => {
  assert.equal(normalizeMobile('not a phone'), null);
  assert.equal(normalizeMobile('+123'), null); // too short for E.164
  assert.equal(normalizeMobile('+1234567890123456'), null); // >15 digits
  assert.equal(normalizeMobile(''), null);
});
