import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigService } from '@nestjs/config';
import { RedisService } from './redis/redis.service';
import { StorageService } from './storage/storage.service';

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
            get: jest.fn(),
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
  });
});
