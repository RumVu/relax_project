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
 * that `aud` matches our `clientId` (prevents replay from other apps'
 * tokens). Returns the verified payload or throws Unauthorized.
 */
export async function verifyGoogleIdToken(
  idToken: string,
  clientId: string,
): Promise<GoogleIdTokenPayload> {
  try {
    const client = new OAuth2Client(clientId);
    const ticket = await client.verifyIdToken({ idToken, audience: clientId });
    return ticket.getPayload() ?? {};
  } catch {
    throw new UnauthorizedException({
      code: ErrorCode.AUTH_INVALID_CREDENTIALS,
      message: 'Google ID token is invalid or expired.',
    });
  }
}
