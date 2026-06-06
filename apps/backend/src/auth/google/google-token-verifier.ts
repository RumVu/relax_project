/**
 * Verify a Google Identity Services ID token.
 * Pure-ish: spins up its own OAuth2Client, no DI required.
 */
import { UnauthorizedException } from '@nestjs/common';
import { OAuth2Client } from 'google-auth-library';
import { ErrorCode } from '../../common/errors/error-code';

export interface GoogleIdTokenPayload {
  email?: string;
  email_verified?: boolean;
  name?: string;
  picture?: string;
  sub?: string;
}

/**
 * Validates the JWT signature against Google's public JWKs and checks
 * that `aud` matches one of our `clientIds` (prevents replay from other
 * apps' tokens). Returns the verified payload or throws Unauthorized.
 *
 * Accepts an array of Client IDs because the same Google project usually
 * has separate OAuth clients per platform (Web / iOS / Android), and
 * each emits ID tokens with that platform's Client ID in `aud`.
 */
export async function verifyGoogleIdToken(
  idToken: string,
  clientIds: string | string[],
): Promise<GoogleIdTokenPayload> {
  const audiences = (
    Array.isArray(clientIds) ? clientIds : [clientIds]
  )
    .map((c) => c.trim())
    .filter((c) => c.length > 0);

  if (audiences.length === 0) {
    throw new UnauthorizedException({
      code: ErrorCode.AUTH_INVALID_CREDENTIALS,
      message: 'No Google Client ID configured on backend.',
    });
  }

  try {
    // First Client ID becomes the OAuth2 client identity; audience is the
    // full allowed list so a token from any of our platforms verifies.
    const client = new OAuth2Client(audiences[0]);
    const ticket = await client.verifyIdToken({
      idToken,
      audience: audiences,
    });
    return ticket.getPayload() ?? {};
  } catch {
    throw new UnauthorizedException({
      code: ErrorCode.AUTH_INVALID_CREDENTIALS,
      message: 'Google ID token is invalid or expired.',
    });
  }
}
