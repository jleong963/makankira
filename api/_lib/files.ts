/**
 * files.ts — uploads to Vercel Blob with metadata in uploaded_files (README
 * Section 9, Screens 3/4). Bytes live in Blob; only URL + metadata in Turso.
 */

import type { Row } from '@libsql/client';
import { put, del } from '@vercel/blob';
import { queryOne, execute, query } from './db.js';
import { newId } from './ids.js';
import { env, envOptional } from './env.js';
import { HttpError } from './http.js';

const FILE_KINDS = ['duitnow_qr', 'menu_image', 'menu_excel', 'export_excel', 'export_csv', 'other'];
const IMAGE_TYPES = ['image/png', 'image/jpeg', 'image/jpg', 'image/webp'];

export function validateFileKind(kind: unknown): string {
  if (typeof kind === 'string' && FILE_KINDS.includes(kind)) return kind;
  throw new HttpError(400, 'invalid_file_kind', `fileKind must be one of ${FILE_KINDS.join(', ')}`);
}

/** QR and menu images must be PNG/JPG/JPEG/WebP (README Section 11). */
export function assertUploadType(kind: string, contentType: string): void {
  if ((kind === 'duitnow_qr' || kind === 'menu_image') && !IMAGE_TYPES.includes(contentType.toLowerCase())) {
    throw new HttpError(400, 'invalid_file_type', 'Image must be PNG, JPG, JPEG, or WebP');
  }
}

export async function uploadFile(args: {
  userId: string;
  mealId: string | null;
  fileKind: string;
  filename: string;
  contentType: string;
  data: Buffer;
}): Promise<Row> {
  const kind = validateFileKind(args.fileKind);
  assertUploadType(kind, args.contentType);

  const safe = (args.filename || 'upload').replace(/[^a-zA-Z0-9._-]/g, '_').slice(0, 80);
  const pathname = `${args.mealId ?? args.userId}/${kind}-${newId('file')}-${safe}`;

  // Fail with a clear, actionable error when storage isn't wired up, rather than
  // the opaque 500 that a raw env()/put() throw would produce.
  const token = envOptional('BLOB_READ_WRITE_TOKEN');
  if (!token) {
    throw new HttpError(
      503,
      'storage_not_configured',
      'File storage is not configured on the server (BLOB_READ_WRITE_TOKEN is missing). Create a Vercel Blob store, connect it to the project, and redeploy.',
    );
  }
  let blob: Awaited<ReturnType<typeof put>>;
  try {
    blob = await put(pathname, args.data, {
      access: 'public',
      contentType: args.contentType,
      token,
    });
  } catch (err) {
    throw new HttpError(
      502,
      'storage_upload_failed',
      `File storage rejected the upload: ${err instanceof Error ? err.message : String(err)}`,
    );
  }

  const id = newId('file');
  await execute(
    `INSERT INTO uploaded_files
       (id, owner_user_id, meal_session_id, file_kind, blob_url, blob_pathname, content_type, size_bytes, original_filename)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [id, args.userId, args.mealId, kind, blob.url, blob.pathname, args.contentType, args.data.length, args.filename],
  );
  return (await queryOne('SELECT * FROM uploaded_files WHERE id = ?', [id]))!;
}

export async function getFile(userId: string, fileId: string): Promise<Row> {
  const row = await queryOne('SELECT * FROM uploaded_files WHERE id = ? AND owner_user_id = ?', [fileId, userId]);
  if (!row) throw new HttpError(404, 'not_found', 'File not found');
  return row;
}

export async function deleteFile(userId: string, fileId: string): Promise<void> {
  const row = await getFile(userId, fileId);
  try {
    await del(String(row.blob_url), { token: env('BLOB_READ_WRITE_TOKEN') });
  } catch {
    // Blob may already be gone; remove the row regardless.
  }
  await query('DELETE FROM uploaded_files WHERE id = ?', [fileId]);
}

/**
 * Delete a file (blob + row) by id, ignoring ownership — for internal cleanup
 * when the last thing referencing it is removed (e.g. a DuitNow-QR payment
 * method). No-op if the file is already gone; blob/storage errors are swallowed
 * so cleanup never blocks the caller.
 */
export async function deleteFileById(fileId: string): Promise<void> {
  const row = await queryOne('SELECT blob_url FROM uploaded_files WHERE id = ?', [fileId]);
  if (!row) return;
  try {
    await del(String(row.blob_url), { token: env('BLOB_READ_WRITE_TOKEN') });
  } catch {
    // Blob already gone or storage not configured — drop the row anyway.
  }
  await query('DELETE FROM uploaded_files WHERE id = ?', [fileId]);
}
