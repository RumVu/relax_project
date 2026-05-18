import { ErrorCode } from '../common/errors/error-code';

type Env = Record<string, string | undefined>;

const requiredKeys = ['DATABASE_URL', 'JWT_SECRET'] as const;

export function validateEnv(config: Env) {
  const missing = requiredKeys.filter((key) => !config[key]);

  if (missing.length > 0) {
    throw new Error(
      `${ErrorCode.CONFIG_MISSING_REQUIRED_ENV}: ${missing.join(', ')}`,
    );
  }

  if (!config.JWT_EXPIRES_IN) {
    config.JWT_EXPIRES_IN = '7d';
  }

  if (!config.PORT) {
    config.PORT = '6823';
  }

  return config;
}
