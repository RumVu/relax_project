import { registerAs } from '@nestjs/config';

export default registerAs('redis', () => ({
  enabled: process.env.REDIS_ENABLED !== 'false',
  url: process.env.REDIS_URL ?? 'redis://localhost:6379',
  keyPrefix: process.env.REDIS_KEY_PREFIX ?? 'dcb:',
  defaultTtlSeconds: Number(process.env.REDIS_DEFAULT_TTL_SECONDS ?? 300),
}));
