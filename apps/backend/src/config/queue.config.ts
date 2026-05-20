import { registerAs } from '@nestjs/config';

export default registerAs('queue', () => ({
  enabled: process.env.QUEUE_ENABLED !== 'false',
  prefix: process.env.QUEUE_PREFIX ?? 'dcb',
  defaultAttempts: Number(process.env.QUEUE_DEFAULT_ATTEMPTS ?? 3),
  backoffDelayMs: Number(process.env.QUEUE_BACKOFF_DELAY_MS ?? 1000),
}));
