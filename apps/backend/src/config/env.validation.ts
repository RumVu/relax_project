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
  // Prefer process.env values to allow overrides in tests and container environments
  const mergedConfig = { ...config };
  for (const key of Object.keys(process.env)) {
    if (process.env[key] !== undefined) {
      mergedConfig[key] = process.env[key];
    }
  }

  const missing = requiredKeys.filter((key) => !mergedConfig[key]);

  if (missing.length > 0) {
    throw new Error(
      `${ErrorCode.CONFIG_MISSING_REQUIRED_ENV}: ${missing.join(', ')}`,
    );
  }

  if (mergedConfig.JWT_SECRET && mergedConfig.JWT_SECRET.length < MIN_JWT_SECRET_LENGTH) {
    throw new Error(
      `${ErrorCode.CONFIG_MISSING_REQUIRED_ENV}: JWT_SECRET must be at least ${MIN_JWT_SECRET_LENGTH} characters`,
    );
  }

  if (mergedConfig.JWT_SECRET && isWeakJwtSecret(mergedConfig.JWT_SECRET)) {
    throw new Error(
      `${ErrorCode.CONFIG_MISSING_REQUIRED_ENV}: JWT_SECRET must be random and must not use placeholder text`,
    );
  }

  if (!mergedConfig.JWT_EXPIRES_IN) {
    mergedConfig.JWT_EXPIRES_IN = '15m';
  }

  if (!mergedConfig.JWT_ISSUER) {
    mergedConfig.JWT_ISSUER = 'digital-cigarette-break-api';
  }

  if (!mergedConfig.JWT_AUDIENCE) {
    mergedConfig.JWT_AUDIENCE = 'digital-cigarette-break-app';
  }

  if (!mergedConfig.CORS_ORIGINS) {
    mergedConfig.CORS_ORIGINS =
      'http://localhost:3000,http://localhost:5300,http://localhost:6823';
  }

  if (!mergedConfig.TRUST_PROXY) {
    mergedConfig.TRUST_PROXY = 'loopback';
  }

  if (!mergedConfig.PORT) {
    mergedConfig.PORT = '6823';
  }

  if (!mergedConfig.REDIS_URL) {
    mergedConfig.REDIS_URL = 'redis://localhost:6379';
  }

  if (!mergedConfig.REDIS_KEY_PREFIX) {
    mergedConfig.REDIS_KEY_PREFIX = 'dcb:';
  }

  if (!mergedConfig.REDIS_DEFAULT_TTL_SECONDS) {
    mergedConfig.REDIS_DEFAULT_TTL_SECONDS = '300';
  }

  if (!mergedConfig.QUEUE_PREFIX) {
    mergedConfig.QUEUE_PREFIX = 'dcb';
  }

  if (!mergedConfig.QUEUE_DEFAULT_ATTEMPTS) {
    mergedConfig.QUEUE_DEFAULT_ATTEMPTS = '3';
  }

  if (!mergedConfig.QUEUE_BACKOFF_DELAY_MS) {
    mergedConfig.QUEUE_BACKOFF_DELAY_MS = '1000';
  }

  if (!mergedConfig.WEEKLY_STATS_QUEUE_WORKER_ENABLED) {
    mergedConfig.WEEKLY_STATS_QUEUE_WORKER_ENABLED = 'false';
  }

  if (!mergedConfig.WEEKLY_STATS_QUEUE_WORKER_CONCURRENCY) {
    mergedConfig.WEEKLY_STATS_QUEUE_WORKER_CONCURRENCY = '2';
  }

  return mergedConfig;
}

function isWeakJwtSecret(value: string) {
  const normalized = value.trim().toLowerCase();
  return WEAK_JWT_SECRET_PATTERNS.some((pattern) =>
    normalized.includes(pattern),
  );
}
