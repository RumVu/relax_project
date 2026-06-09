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
  // Google OAuth client IDs. We can accept separate variables per environment
  // and join them into a comma-separated string for the auth service to verify.
  googleClientId: [
    process.env.GOOGLE_CLIENT_ID,
    process.env.GOOGLE_CLIENT_ID_ANDROID,
    process.env.GOOGLE_CLIENT_ID_IOS,
    process.env.GOOGLE_CLIENT_ID_WEB,
  ]
    .filter(Boolean)
    .join(','),
  googleClientSecret: process.env.GOOGLE_CLIENT_SECRET ?? '',
  googleRedirectUri: process.env.GOOGLE_REDIRECT_URI ?? '',
}));
