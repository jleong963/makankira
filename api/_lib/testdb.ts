/**
 * testdb.ts — test-only helper. Creates a fresh temp-file SQLite database with
 * the NATIVE libSQL driver (the web client can't open file: URLs) and injects it
 * into db.ts via setClient(), then applies every migration in order (so tests
 * see the same schema as production). Not imported by any handler, so the native
 * driver never reaches the Vercel function bundle.
 */

import { readFileSync, readdirSync } from 'node:fs';
import { resolve, dirname } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { tmpdir } from 'node:os';
import { createClient } from '@libsql/client';
import { setClient } from './db.js';

export async function setupTestDb(): Promise<string> {
  const file = resolve(tmpdir(), `mk-test-${process.pid}-${Date.now()}.db`);
  const client = createClient({ url: pathToFileURL(file).href });
  setClient(client);

  const dir = resolve(dirname(fileURLToPath(import.meta.url)), '..', '..', 'migrations');
  const files = readdirSync(dir)
    .filter((f) => f.endsWith('.sql'))
    .sort();
  for (const f of files) {
    await client.executeMultiple(readFileSync(resolve(dir, f), 'utf8'));
  }
  return file;
}
