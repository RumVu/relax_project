import { registerAs } from '@nestjs/config';

export default registerAs('app', () => ({
  port: Number(process.env.PORT ?? 6823),
  nodeEnv: process.env.NODE_ENV ?? 'development',
  corsOrigins: process.env.CORS_ORIGINS,
  trustProxy: process.env.TRUST_PROXY ?? 'loopback',
  swaggerEnabled: process.env.SWAGGER_ENABLED,
  swaggerPublic: process.env.SWAGGER_PUBLIC,
  swaggerBasicUser: process.env.SWAGGER_BASIC_USER,
  swaggerBasicPassword: process.env.SWAGGER_BASIC_PASSWORD,
  authRefreshCookieName:
    process.env.AUTH_REFRESH_COOKIE_NAME ?? 'relax_refresh_token',
  authRefreshCookieSecure: process.env.AUTH_REFRESH_COOKIE_SECURE,
  authRefreshCookieSameSite: process.env.AUTH_REFRESH_COOKIE_SAME_SITE,
  // Google Identity Services client ID (web). Same value must be set
  // in NEXT_PUBLIC_GOOGLE_CLIENT_ID on the web so the ID token
  // audience matches. Leaving this empty disables /auth/google.
  googleClientId: process.env.GOOGLE_CLIENT_ID ?? '',
}));
