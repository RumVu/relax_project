import { Logger } from '@nestjs/common';
import { EmailPayload, EmailProvider, EmailSendResult } from '../email.types';

/**
 * SendGrid provider — talks to https://api.sendgrid.com/v3/mail/send directly.
 */
export class SendGridEmailProvider implements EmailProvider {
  readonly name = 'sendgrid';
  private readonly logger = new Logger('Email:sendgrid');

  constructor(
    private readonly apiKey: string,
    private readonly from: string,
  ) {}

  async send(payload: EmailPayload): Promise<EmailSendResult> {
    try {
      const res = await fetch('https://api.sendgrid.com/v3/mail/send', {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
        },
        body: JSON.stringify({
          personalizations: [{ to: [{ email: payload.to }] }],
          from: { email: this.from },
          subject: payload.subject,
          content: [
            { type: 'text/plain', value: payload.text },
            { type: 'text/html', value: payload.html },
          ],
          custom_args: { purpose: payload.purpose },
        }),
      });
      if (!res.ok) {
        const text = await res.text().catch(() => '');
        this.logger.warn(`SendGrid send failed: HTTP ${res.status} ${text}`);
        return {
          provider: this.name,
          delivered: false,
          error: `HTTP ${res.status}`,
        };
      }
      // SendGrid returns 202 with no body, but the X-Message-Id header.
      return {
        provider: this.name,
        delivered: true,
        messageId: res.headers.get('x-message-id') ?? undefined,
      };
    } catch (err: any) {
      this.logger.error(`SendGrid network error: ${err?.message}`);
      return { provider: this.name, delivered: false, error: err?.message };
    }
  }
}
