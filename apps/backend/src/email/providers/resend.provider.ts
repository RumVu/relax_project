import { Logger } from '@nestjs/common';
import { EmailPayload, EmailProvider, EmailSendResult } from '../email.types';

/**
 * Resend provider — talks to https://api.resend.com directly so we don't
 * pull in the `resend` SDK just for one POST.
 */
export class ResendEmailProvider implements EmailProvider {
  readonly name = 'resend';
  private readonly logger = new Logger('Email:resend');

  constructor(
    private readonly apiKey: string,
    private readonly from: string,
  ) {}

  async send(payload: EmailPayload): Promise<EmailSendResult> {
    try {
      const res = await fetch('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          from: this.from,
          to: [payload.to],
          subject: payload.subject,
          html: payload.html,
          text: payload.text,
          tags: [{ name: 'purpose', value: payload.purpose }],
        }),
      });
      const body = (await res.json().catch(() => null)) as
        | { id?: string; message?: string }
        | null;
      if (!res.ok) {
        const message = body?.message ?? `HTTP ${res.status}`;
        this.logger.warn(`Resend send failed: ${message}`);
        return { provider: this.name, delivered: false, error: message };
      }
      return {
        provider: this.name,
        delivered: true,
        messageId: body?.id,
      };
    } catch (err: any) {
      this.logger.error(`Resend network error: ${err?.message}`);
      return { provider: this.name, delivered: false, error: err?.message };
    }
  }
}
