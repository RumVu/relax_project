import { ErrorCode } from '../common/errors/error-code';

type Env = Record<string, string | undefined>;

const requiredKeys = ['DATABASE_URL', 'JWT_SECRET'] as const;
const MIN_JWT_SECRET_LENGTH = 32;
const WEAK_JWT_SECRET_PATTERNS = [
  'secret',
  'changeme',
  'change-me',
  'replace-me',
  'your-secret',
  'your_jwt_secret',
  'jwt_secret',
  'development',
] as const;

export function validateEnv(config: Env) {
  const missing = requiredKeys.filter((key) => !config[key]);

  if (missing.length > 0) {
    throw new Error(
      `${ErrorCode.CONFIG_MISSING_REQUIRED_ENV}: ${missing.join(', ')}`,
    );
  }

  if (config.JWT_SECRET && config.JWT_SECRET.length < MIN_JWT_SECRET_LENGTH) {
    throw new Error(
      `${ErrorCode.CONFIG_MISSING_REQUIRED_ENV}: JWT_SECRET must be at least ${MIN_JWT_SECRET_LENGTH} characters`,
    );
  }

  if (config.JWT_SECRET && isWeakJwtSecret(config.JWT_SECRET)) {
    throw new Error(
      `${ErrorCode.CONFIG_MISSING_REQUIRED_ENV}: JWT_SECRET must be random and must not use placeholder text`,
    );
  }

  if (!config.JWT_EXPIRES_IN) {
    config.JWT_EXPIRES_IN = '15m';
  }

  if (!config.JWT_ISSUER) {
    config.JWT_ISSUER = 'digital-cigarette-break-api';
  }

  if (!config.JWT_AUDIENCE) {
    config.JWT_AUDIENCE = 'digital-cigarette-break-app';
  }

  if (!config.CORS_ORIGINS) {
    config.CORS_ORIGINS =
      'http://localhost:3000,http://localhost:5300,http://localhost:6823';
  }

  if (!config.TRUST_PROXY) {
    config.TRUST_PROXY = 'loopback';
  }

  if (!config.PORT) {
    config.PORT = '6823';
  }

  if (!config.REDIS_URL) {
    config.REDIS_URL = 'redis://localhost:6379';
  }

  if (!config.REDIS_KEY_PREFIX) {
    config.REDIS_KEY_PREFIX = 'dcb:';
  }

  if (!config.REDIS_DEFAULT_TTL_SECONDS) {
    config.REDIS_DEFAULT_TTL_SECONDS = '300';
  }

  if (!config.QUEUE_PREFIX) {
    config.QUEUE_PREFIX = 'dcb';
  }

  if (!config.QUEUE_DEFAULT_ATTEMPTS) {
    config.QUEUE_DEFAULT_ATTEMPTS = '3';
  }

  if (!config.QUEUE_BACKOFF_DELAY_MS) {
    config.QUEUE_BACKOFF_DELAY_MS = '1000';
  }

  if (!config.WEEKLY_STATS_QUEUE_WORKER_ENABLED) {
    config.WEEKLY_STATS_QUEUE_WORKER_ENABLED = 'false';
  }

  if (!config.WEEKLY_STATS_QUEUE_WORKER_CONCURRENCY) {
    config.WEEKLY_STATS_QUEUE_WORKER_CONCURRENCY = '2';
  }

  return config;
}

function isWeakJwtSecret(value: string) {
  const normalized = value.trim().toLowerCase();
  return WEAK_JWT_SECRET_PATTERNS.some((pattern) =>
    normalized.includes(pattern),
  );
}
