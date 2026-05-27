import { Test, TestingModule } from '@nestjs/testing';
import {
  INestApplication,
  RequestMethod,
  ValidationPipe,
} from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { HttpExceptionFilter } from './../src/common/errors/http-exception.filter';

// Mirrors the global prefix applied in main.ts so the versioning contract is
// asserted: API routes live under /v1, infra/index routes stay unversioned.
describe('API versioning (e2e)', () => {
  let app: INestApplication<App>;

  beforeAll(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
    app.setGlobalPrefix('v1', {
      exclude: [
        { path: '/', method: RequestMethod.GET },
        { path: 'api', method: RequestMethod.GET },
        { path: 'health', method: RequestMethod.GET },
        { path: 'ready', method: RequestMethod.GET },
      ],
    });
    app.useGlobalPipes(
      new ValidationPipe({
        whitelist: true,
        forbidNonWhitelisted: true,
        transform: true,
      }),
    );
    app.useGlobalFilters(new HttpExceptionFilter());
    await app.init();
  });

  afterAll(async () => {
    await app.close();
  });

  it('serves API routes under the /v1 prefix', async () => {
    await request(app.getHttpServer())
      .get('/v1/mood-checkins/options')
      .expect(200)
      .expect(({ body }) => {
        expect(Array.isArray(body)).toBe(true);
      });
  });

  it('no longer serves API routes at the unversioned path', async () => {
    await request(app.getHttpServer())
      .get('/mood-checkins/options')
      .expect(404);
  });

  it('keeps index and health routes unversioned', async () => {
    await request(app.getHttpServer())
      .get('/')
      .expect(200)
      .expect(({ body }) => {
        expect(body.name).toBe('Digital Cigarette Break API');
      });
    await request(app.getHttpServer())
      .get('/health')
      .expect(200)
      .expect(({ body }) => {
        expect(body.status).toBe('ok');
      });
  });

  it('does not expose health at a versioned path', async () => {
    await request(app.getHttpServer()).get('/v1/health').expect(404);
  });
});
