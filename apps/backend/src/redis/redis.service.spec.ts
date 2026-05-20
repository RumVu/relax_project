import { ConfigService } from '@nestjs/config';
import { RedisService } from './redis.service';

describe('RedisService', () => {
  it('falls back to local throttling when Redis is unavailable', async () => {
    const configService = {
      get: jest.fn((key: string) => {
        if (key === 'redis.enabled') {
          return false;
        }

        if (key === 'redis.defaultTtlSeconds') {
          return 300;
        }

        return undefined;
      }),
    } as unknown as ConfigService;
    const service = new RedisService(configService);

    await expect(
      service.incrementThrottle('1.2.3.4', 60_000, 2, 60_000, 'auth-login'),
    ).resolves.toMatchObject({ totalHits: 1, isBlocked: false });
    await expect(
      service.incrementThrottle('1.2.3.4', 60_000, 2, 60_000, 'auth-login'),
    ).resolves.toMatchObject({ totalHits: 2, isBlocked: false });
    await expect(
      service.incrementThrottle('1.2.3.4', 60_000, 2, 60_000, 'auth-login'),
    ).resolves.toMatchObject({ totalHits: 3, isBlocked: true });

    service.onModuleDestroy();
  });
});
