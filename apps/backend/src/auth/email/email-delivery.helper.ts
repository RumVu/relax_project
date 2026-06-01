/**
 * Email delivery descriptor for email-verification / password-reset.
 *
 * We don't actually ship an email yet — when no provider is configured
 * we return the plain token in `devToken` so dev can copy it from the
 * response. In production with a provider configured the token is
 * suppressed and the response says `queued: true`.
 */
import { ConfigService } from '@nestjs/config';

export interface EmailDeliveryDescriptor {
  channel: 'email';
  purpose: string;
  provider: string;
  configured: boolean;
  queued: boolean;
  devToken?: string;
}

/**
 * Build the descriptor from a ConfigService. Lives outside the
 * AuthService so any new flow (e.g. magic-link login) can reuse it.
 */
export function buildEmailDelivery(
  configService: ConfigService,
  purpose: string,
  plainToken?: string,
): EmailDeliveryDescriptor {
  const provider = configService.get<string>('EMAIL_PROVIDER') ?? 'none';
  const configured =
    Boolean(configService.get<string>('RESEND_API_KEY')) ||
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
