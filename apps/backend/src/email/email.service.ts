import { Injectable, Logger, OnModuleInit } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { LogEmailProvider } from './providers/log.provider';
import { ResendEmailProvider } from './providers/resend.provider';
import { SendGridEmailProvider } from './providers/sendgrid.provider';
import { SmtpEmailProvider } from './providers/smtp.provider';
import {
  EmailPayload,
  EmailProvider,
  EmailSendResult,
} from './email.types';
import {
  resetPasswordTemplate,
  verifyEmailTemplate,
} from './email-templates';

/**
 * EmailService — picks a provider at boot and renders templates.
 *
 * Provider selection priority:
 *   1. EMAIL_PROVIDER env (`resend` | `smtp` | `sendgrid` | `log`) if set.
 *   2. Auto-detect: RESEND_API_KEY → resend, SMTP_URL → smtp,
 *      SENDGRID_API_KEY → sendgrid.
 *   3. Fallback: log provider (writes email to the application log).
 *
 * `isConfigured()` mirrors what `buildEmailDelivery()` checks so the
 * `devToken` surfacing logic still works.
 */
@Injectable()
export class EmailService implements OnModuleInit {
  private readonly logger = new Logger(EmailService.name);
  private provider!: EmailProvider;
  private fromAddress!: string;
  private appBaseUrl!: string;

  constructor(private readonly configService: ConfigService) {}

  onModuleInit() {
    this.fromAddress =
      this.configService.get<string>('EMAIL_FROM') ?? 'noreply@relax.local';
    this.appBaseUrl =
      this.configService.get<string>('APP_BASE_URL') ??
      this.configService.get<string>('FRONTEND_URL') ??
      '';
    this.provider = this.selectProvider();
    this.logger.log(
      `EmailService ready: provider=${this.provider.name} from="${this.fromAddress}"`,
    );
  }

  private selectProvider(): EmailProvider {
    const explicit = (
      this.configService.get<string>('EMAIL_PROVIDER') ?? ''
    ).toLowerCase();
    const resendKey = this.configService.get<string>('RESEND_API_KEY');
    const smtpUrl = this.configService.get<string>('SMTP_URL');
    const sendgridKey = this.configService.get<string>('SENDGRID_API_KEY');

    const pick = explicit || this.autoPick(resendKey, smtpUrl, sendgridKey);

    switch (pick) {
      case 'resend':
        if (!resendKey) {
          this.logger.warn(
            'EMAIL_PROVIDER=resend but RESEND_API_KEY is missing; falling back to log provider.',
          );
          return new LogEmailProvider();
        }
        return new ResendEmailProvider(resendKey, this.fromAddress);
      case 'smtp':
        if (!smtpUrl) {
          this.logger.warn(
            'EMAIL_PROVIDER=smtp but SMTP_URL is missing; falling back to log provider.',
          );
          return new LogEmailProvider();
        }
        return new SmtpEmailProvider(smtpUrl, this.fromAddress);
      case 'sendgrid':
        if (!sendgridKey) {
          this.logger.warn(
            'EMAIL_PROVIDER=sendgrid but SENDGRID_API_KEY is missing; falling back to log provider.',
          );
          return new LogEmailProvider();
        }
        return new SendGridEmailProvider(sendgridKey, this.fromAddress);
      default:
        return new LogEmailProvider();
    }
  }

  private autoPick(
    resendKey?: string,
    smtpUrl?: string,
    sendgridKey?: string,
  ): string {
    if (resendKey) return 'resend';
    if (smtpUrl) return 'smtp';
    if (sendgridKey) return 'sendgrid';
    return 'log';
  }

  /** True when a real outbound provider (not `log`) is wired. */
  isConfigured(): boolean {
    return this.provider.name !== 'log';
  }

  providerName(): string {
    return this.provider.name;
  }

  async sendRaw(payload: EmailPayload): Promise<EmailSendResult> {
    return this.provider.send(payload);
  }

  async sendVerifyEmail(opts: {
    to: string;
    displayName?: string | null;
    token: string;
    ttlMinutes: number;
  }): Promise<EmailSendResult> {
    const verifyUrl = this.appBaseUrl
      ? `${this.appBaseUrl.replace(/\/$/, '')}/auth/verify-email?token=${encodeURIComponent(opts.token)}`
      : undefined;
    const tmpl = verifyEmailTemplate({
      displayName: opts.displayName,
      token: opts.token,
      verifyUrl,
      ttlMinutes: opts.ttlMinutes,
    });
    return this.provider.send({
      to: opts.to,
      subject: tmpl.subject,
      html: tmpl.html,
      text: tmpl.text,
      purpose: 'verify-email',
    });
  }

  async sendPasswordReset(opts: {
    to: string;
    displayName?: string | null;
    token: string;
    ttlMinutes: number;
  }): Promise<EmailSendResult> {
    const resetUrl = this.appBaseUrl
      ? `${this.appBaseUrl.replace(/\/$/, '')}/auth/reset-password?token=${encodeURIComponent(opts.token)}`
      : undefined;
    const tmpl = resetPasswordTemplate({
      displayName: opts.displayName,
      token: opts.token,
      resetUrl,
      ttlMinutes: opts.ttlMinutes,
    });
    return this.provider.send({
      to: opts.to,
      subject: tmpl.subject,
      html: tmpl.html,
      text: tmpl.text,
      purpose: 'reset-password',
    });
  }
}
