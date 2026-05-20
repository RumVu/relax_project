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
}));
