/**
 * Email delivery descriptor for email-verification / password-reset.
 *
 * When a real provider is wired (EmailService.isConfigured()), the token
 * is suppressed and we report `queued: true`. When only the log provider
 * is active (dev/local), we surface the token in `devToken` so it can
 * be copy-pasted into the verify/reset flows.
 */
import { ConfigService } from '@nestjs/config';
import type { EmailService } from '../../email/email.service';

export interface EmailDeliveryDescriptor {
  channel: 'email';
  purpose: string;
  provider: string;
  configured: boolean;
  queued: boolean;
  devToken?: string;
}

/**
 * Build the descriptor. Pass `emailService` to read the actually-selected
 * provider name; without it we report `provider: 'unknown'` (legacy callers).
 */
export function buildEmailDelivery(
  configService: ConfigService,
  purpose: string,
  plainToken?: string,
  emailService?: EmailService,
): EmailDeliveryDescriptor {
  const provider =
    emailService?.providerName() ??
    configService.get<string>('EMAIL_PROVIDER') ??
    'unknown';
  const configured = emailService
    ? emailService.isConfigured()
    : Boolean(configService.get<string>('RESEND_API_KEY')) ||
      Boolean(configService.get<string>('SENDGRID_API_KEY')) ||
      Boolean(configService.get<string>('SMTP_URL'));
  const nodeEnv =
    configService.get<string>('app.nodeEnv') ??
    process.env.NODE_ENV ??
    'development';

  return {
    channel: 'email',
    purpose,
    provider,
    configured,
    queued: configured,
    devToken: !configured && nodeEnv === 'development' ? plainToken : undefined,
  };
}

const ONE_DAY_MS = 1000 * 60 * 60 * 24;
const THIRTY_MIN_MS = 1000 * 60 * 30;
const TEN_MIN_MS = 1000 * 60 * 10;

export function getEmailVerificationTtlMs(
  configService: ConfigService,
): number {
  return Number(
    configService.get<string>('EMAIL_VERIFICATION_TTL_MS') ?? ONE_DAY_MS,
  );
}

export function getPasswordResetTtlMs(configService: ConfigService): number {
  return Number(
    configService.get<string>('PASSWORD_RESET_TTL_MS') ?? THIRTY_MIN_MS,
  );
}

export function getOtpTtlMs(configService: ConfigService): number {
  return Number(configService.get<string>('OTP_TTL_MS') ?? TEN_MIN_MS);
}
