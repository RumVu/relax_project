import { Logger } from '@nestjs/common';
import * as nodemailer from 'nodemailer';
import type { Transporter } from 'nodemailer';
import { EmailPayload, EmailProvider, EmailSendResult } from '../email.types';

/**
 * SMTP provider via nodemailer — supports plain SMTP URL (smtp://user:pass@host:port)
 * which covers Mailtrap, Gmail SMTP, Mailgun SMTP, Office 365, self-hosted, etc.
 */
export class SmtpEmailProvider implements EmailProvider {
  readonly name = 'smtp';
  private readonly logger = new Logger('Email:smtp');
  private readonly transporter: Transporter;

  constructor(
    smtpUrl: string,
    private readonly from: string,
  ) {
    this.transporter = nodemailer.createTransport(smtpUrl);
  }

  async send(payload: EmailPayload): Promise<EmailSendResult> {
    try {
      const info = await this.transporter.sendMail({
        from: this.from,
        to: payload.to,
        subject: payload.subject,
        html: payload.html,
        text: payload.text,
        headers: { 'X-Purpose': payload.purpose },
      });
      return {
        provider: this.name,
        delivered: true,
        messageId: info.messageId,
      };
    } catch (err: any) {
      this.logger.error(`SMTP send failed: ${err?.message}`);
      return { provider: this.name, delivered: false, error: err?.message };
    }
  }
}
