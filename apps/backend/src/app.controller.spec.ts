import { Test, TestingModule } from '@nestjs/testing';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { ConfigService } from '@nestjs/config';
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
