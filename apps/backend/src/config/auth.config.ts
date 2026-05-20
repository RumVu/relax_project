import { registerAs } from '@nestjs/config';

export default registerAs('auth', () => ({
  jwtSecret: process.env.JWT_SECRET,
  jwtExpiresIn: process.env.JWT_EXPIRES_IN ?? '15m',
  jwtIssuer: process.env.JWT_ISSUER ?? 'digital-cigarette-break-api',
  jwtAudience: process.env.JWT_AUDIENCE ?? 'digital-cigarette-break-app',
}));
