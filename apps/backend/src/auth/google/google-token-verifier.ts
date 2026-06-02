/**
 * Verify a Google Identity Services ID token.
 * Pure-ish: spins up its own OAuth2Client, no DI required.
 */
import { UnauthorizedException } from '@nestjs/common';
import { OAuth2Client, type Credentials } from 'google-auth-library';
import { ErrorCode } from '../../common/errors/error-code';

export interface GoogleIdTokenPayload {
  email?: string;
  email_verified?: boolean;
  name?: string;
  picture?: string;
  sub?: string;
}

interface GoogleTokenInfoResponse {
  aud?: string;
  email?: string;
  email_verified?: string | boolean;
}

interface GoogleUserInfoResponse {
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

/**
 * Validates a GIS OAuth access token, confirms it was issued to our
 * Google client, then reads the user's profile from Google userinfo.
 */
export async function verifyGoogleAccessToken(
  accessToken: string,
  clientId: string,
): Promise<GoogleIdTokenPayload> {
  try {
    const tokenInfoResponse = await fetch(
      `https://oauth2.googleapis.com/tokeninfo?access_token=${encodeURIComponent(
        accessToken,
      )}`,
    );
    if (!tokenInfoResponse.ok) {
      throw new Error('Token info request failed');
    }

    const tokenInfo =
      (await tokenInfoResponse.json()) as GoogleTokenInfoResponse;
    if (tokenInfo.aud !== clientId) {
      throw new Error('Google token audience mismatch');
    }

    const userInfoResponse = await fetch(
      'https://www.googleapis.com/oauth2/v3/userinfo',
      { headers: { Authorization: `Bearer ${accessToken}` } },
    );
    if (!userInfoResponse.ok) {
      throw new Error('User info request failed');
    }

    const userInfo = (await userInfoResponse.json()) as GoogleUserInfoResponse;

    return {
      email: userInfo.email ?? tokenInfo.email,
      email_verified:
        userInfo.email_verified === true ||
        tokenInfo.email_verified === true ||
        tokenInfo.email_verified === 'true',
      name: userInfo.name,
      picture: userInfo.picture,
      sub: userInfo.sub,
    };
  } catch {
    throw new UnauthorizedException({
      code: ErrorCode.AUTH_INVALID_CREDENTIALS,
      message: 'Google access token is invalid or expired.',
    });
  }
}

export async function exchangeGoogleAuthorizationCode(
  authorizationCode: string,
  clientId: string,
  clientSecret: string,
  redirectUri: string,
): Promise<GoogleIdTokenPayload> {
  try {
    const client = new OAuth2Client(clientId, clientSecret, redirectUri);
    const { tokens } = await client.getToken(authorizationCode);
    return resolveGoogleTokens(tokens, clientId);
  } catch {
    throw new UnauthorizedException({
      code: ErrorCode.AUTH_INVALID_CREDENTIALS,
      message: 'Google authorization code is invalid or expired.',
    });
  }
}

async function resolveGoogleTokens(
  tokens: Credentials,
  clientId: string,
): Promise<GoogleIdTokenPayload> {
  if (tokens.id_token) {
    return verifyGoogleIdToken(tokens.id_token, clientId);
  }

  if (tokens.access_token) {
    return verifyGoogleAccessToken(tokens.access_token, clientId);
  }

  throw new UnauthorizedException({
    code: ErrorCode.AUTH_INVALID_CREDENTIALS,
    message: 'Google did not return usable auth tokens.',
  });
}
