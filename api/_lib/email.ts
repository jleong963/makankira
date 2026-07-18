/**
 * email.ts — Gmail SMTP sender (nodemailer). No domain needed: Gmail
 * authenticates the send itself (DKIM/SPF align to gmail.com), so mail lands in
 * the inbox; free tier ~500 recipients/day. Shared by the reminder cron and the
 * "orders finalized" order-sheet email. Best-effort — callers get a boolean.
 */

import nodemailer from 'nodemailer';

export interface MailAttachment {
  filename: string;
  content: Buffer;
  contentType?: string;
}

/** True when Gmail SMTP credentials are configured. */
export function emailConfigured(): boolean {
  return Boolean(process.env.GMAIL_USER && process.env.GMAIL_APP_PASSWORD);
}

let _transport: nodemailer.Transporter | null = null;

function gmailTransport(): nodemailer.Transporter | null {
  const user = process.env.GMAIL_USER;
  const pass = process.env.GMAIL_APP_PASSWORD;
  if (!user || !pass) return null;
  if (!_transport) {
    _transport = nodemailer.createTransport({
      host: 'smtp.gmail.com',
      port: 465,
      secure: true,
      auth: { user, pass },
      // Bound the worst case so a stuck SMTP can't hang a request that awaits a
      // send (finalize) or a cron run.
      connectionTimeout: 10_000,
      greetingTimeout: 10_000,
      socketTimeout: 20_000,
    });
  }
  return _transport;
}

/**
 * Send a plain-text email (optionally with attachments) from the app's Gmail.
 * Returns true on success, or false when unconfigured / no recipient / the send
 * failed. Never throws — email is always a best-effort side channel.
 */
export async function sendEmail(
  to: string,
  subject: string,
  body: string,
  attachments?: MailAttachment[],
): Promise<boolean> {
  const transport = gmailTransport();
  if (!transport || !to) return false;
  try {
    await transport.sendMail({
      // Gmail forces the from-address to the authenticated account; only the
      // display name is free-form.
      from: `MakanKira <${process.env.GMAIL_USER}>`,
      to,
      subject,
      text: body,
      attachments,
    });
    return true;
  } catch (e) {
    console.error('email send failed:', e);
    return false;
  }
}
