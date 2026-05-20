import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { HttpExceptionFilter } from './../src/common/errors/http-exception.filter';

describe('AppController (e2e)', () => {
  let app: INestApplication<App>;

  beforeEach(async () => {
    const moduleFixture: TestingModule = await Test.createTestingModule({
      imports: [AppModule],
    }).compile();

    app = moduleFixture.createNestApplication();
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

  afterEach(async () => {
    await app.close();
  });

  it('/ (GET)', () => {
    return request(app.getHttpServer())
      .get('/')
      .expect(200)
      .expect(({ body }) => {
        expect(body.name).toBe('Digital Cigarette Break API');
        expect(body.docs.swagger).toBe('/docs');
        expect(body.health).toBe('/health');
        expect(body.redis).toBeUndefined();
        expect(body.resources).toBeUndefined();
      });
  });

  it('/api (GET)', () => {
    return request(app.getHttpServer())
      .get('/api')
      .expect(200)
      .expect(({ body }) => {
        expect(body.name).toBe('Digital Cigarette Break API');
        expect(body.docs.openApiJson).toBe('/docs-json');
        expect(body.storage).toBeUndefined();
      });
  });

  it('/health (GET)', () => {
    return request(app.getHttpServer())
      .get('/health')
      .expect(200)
      .expect(({ body }) => {
        expect(body.status).toBe('ok');
        expect(body.timestamp).toBeDefined();
        expect(body.database).toBeUndefined();
      });
  });

  it('/redis/health (GET) requires auth', () => {
    return request(app.getHttpServer()).get('/redis/health').expect(401);
  });

  it('/queues/health (GET) requires auth', () => {
    return request(app.getHttpServer()).get('/queues/health').expect(401);
  });

  it('/realtime/health (GET) requires auth', () => {
    return request(app.getHttpServer()).get('/realtime/health').expect(401);
  });
});
