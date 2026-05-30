/**
 * Pure helpers used across AuthService. No Prisma, no DI.
 */
import { UnauthorizedException } from '@nestjs/common';
import { createHash } from 'node:crypto';
import { ErrorCode } from '../../common/errors/error-code';

/**
 * Bcrypt hash of "this-account-does-not-exist". Used in the login flow
 * to keep timing constant: we always bcrypt-compare against *some* hash
 * even when the email isn't found, so an attacker can't enumerate
 * accounts by measuring response time.
 */
export const DUMMY_PASSWORD_HASH =
  '$2b$12$CwTycUXWue0Thq9StjUM0uJ8GQp/NxYMd6xiDfV3QzL/XU0.D1lu.';

/** SHA-256 hex digest. Used to store refresh tokens + account tokens. */
export function hashToken(token: string): string {
  return createHash('sha256').update(token).digest('hex');
}

/**
 * Throws the unified "credentials wrong" error. Single function so login
 * never accidentally leaks whether the email or password was the wrong
 * half. `never` return so TypeScript narrows after a call.
 */
export function throwInvalidCredentials(): never {
  throw new UnauthorizedException({
    code: ErrorCode.AUTH_INVALID_CREDENTIALS,
    message: 'Email or password is incorrect',
  });
}

/**
 * Short human-readable label for a User-Agent. Mirrors the web's UA
 * parser in spirit but stays tiny so it doesn't pull in a dependency.
 * Used in the "new device login" notification body.
 */
export function summariseUserAgent(ua?: string): string {
  if (!ua) return 'thiết bị không xác định';
  const lower = ua.toLowerCase();

  // OS
  let os = 'máy lạ';
  if (/iphone/.test(lower)) os = 'iPhone';
  else if (/ipad/.test(lower)) os = 'iPad';
  else if (/android/.test(lower))
    os = /mobile/.test(lower) ? 'Android' : 'Android Tablet';
  else if (/mac os x|macintosh/.test(lower)) os = 'Mac';
  else if (/windows/.test(lower)) os = 'Windows';
  else if (/linux/.test(lower)) os = 'Linux';
  else if (/curl/.test(lower)) os = 'curl';

  // Browser
  let browser = '';
  if (/edg\//.test(lower)) browser = 'Edge';
  else if (/coc_coc|coccoc/.test(lower)) browser = 'Cốc Cốc';
  else if (/brave/.test(lower)) browser = 'Brave';
  else if (/opr\/|opera/.test(lower)) browser = 'Opera';
  else if (/firefox|fxios/.test(lower)) browser = 'Firefox';
  else if (/samsungbrowser/.test(lower)) browser = 'Samsung Internet';
  else if (/crios|chrome/.test(lower)) browser = 'Chrome';
  else if (/safari/.test(lower)) browser = 'Safari';
  else if (/curl/.test(lower)) browser = 'curl';

  return browser ? `${browser} trên ${os}` : os;
}
