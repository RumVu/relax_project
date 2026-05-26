import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigService } from '@nestjs/config';
import { QueuesService } from './queues/queues.service';
import { RealtimeService } from './realtime/realtime.service';
import { RedisService } from './redis/redis.service';
import { StorageService } from './storage/storage.service';
import { PrismaService } from './prisma/prisma.service';

describe('AppController', () => {
  let appController: AppController;

  beforeEach(async () => {
    const app: TestingModule = await Test.createTestingModule({
      controllers: [AppController],
      providers: [
        AppService,
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn((key: string) => {
              const values: Record<string, string> = {
                'storage.supabaseBucket': 'test',
                'storage.supabaseUrl': 'https://example.supabase.co',
                'storage.supabasePublishableKey': 'sb_publishable_test',
              };

              return values[key];
            }),
          },
        },
        {
          provide: PrismaService,
          useValue: {
            $queryRaw: jest.fn(() => Promise.resolve([{ '?column?': 1 }])),
          },
        },
        {
          provide: QueuesService,
          useValue: {
            getStatus: jest.fn(() => ({
              configured: true,
              enabled: true,
              provider: 'bullmq',
              redisUrl: 'redis://localhost:6379',
              prefix: 'dcb',
              defaultAttempts: 3,
              backoffDelayMs: 1000,
              registeredQueues: [],
            })),
          },
        },
        {
          provide: RealtimeService,
          useValue: {
            getStatus: jest.fn(() => ({
              configured: true,
              provider: 'socket.io',
              namespace: '/realtime',
              connectedClients: 0,
            })),
          },
        },
        {
          provide: RedisService,
          useValue: {
            getStatus: jest.fn(() => ({
              configured: true,
              enabled: true,
              provider: 'redis',
              url: 'redis://localhost:6379',
              keyPrefix: 'test:',
              defaultTtlSeconds: 300,
            })),
          },
        },
        {
          provide: StorageService,
          useValue: {
            getStatus: jest.fn(() => ({
              configured: true,
              provider: 'supabase',
              bucket: 'test',
              missingKeys: [],
              invalidKeys: [],
              urlValid: true,
            })),
          },
        },
      ],
    }).compile();

    appController = app.get<AppController>(AppController);
  });

  describe('root', () => {
    it('should return API index', () => {
      expect(appController.getApiIndex()).toMatchObject({
        name: 'Digital Cigarette Break API',
        status: 'ok',
        docs: {
          swagger: '/docs',
          openApiJson: '/docs-json',
        },
      });
    });

    it('should return deep readiness checks', async () => {
      await expect(appController.getReady()).resolves.toMatchObject({
        status: 'ok',
        checks: {
          database: { ok: true },
          storage: { configured: true, bucket: 'test' },
        },
      });
    });
  });
});
