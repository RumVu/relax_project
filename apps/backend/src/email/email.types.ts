/**
 * Email service contract.
 *
 * Providers (Resend, SMTP, SendGrid, log-only) implement EmailProvider
 * and EmailService picks one at boot based on env. Callers just hand
 * over a payload — they don't care which transport is wired.
 */

export interface EmailPayload {
  to: string;
  subject: string;
  html: string;
  text: string;
  /** Purpose tag for logging — e.g. 'verify-email', 'reset-password'. */
  purpose: string;
}

export interface EmailSendResult {
  /** Provider name actually used. */
  provider: string;
  /** True when the provider acknowledged the send. */
  delivered: boolean;
  /** Provider-side message id, if returned. */
  messageId?: string;
  /** Error message if the send failed. */
  error?: string;
}

export interface EmailProvider {
  readonly name: string;
  send(payload: EmailPayload): Promise<EmailSendResult>;
}
