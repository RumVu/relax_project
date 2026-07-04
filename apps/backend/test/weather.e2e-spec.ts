import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { ErrorCode } from './../src/common/errors/error-code';
import { HttpExceptionFilter } from './../src/common/errors/http-exception.filter';
import { PrismaService } from './../src/prisma/prisma.service';
import { registerAndVerify } from './helpers/register-and-verify';

describe('Weather APIs (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  const tag = `e2e-weather-${Date.now()}`;
  const email = `${tag}@example.com`;
  const password = 'Secret123!x';

  beforeAll(async () => {
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
    prisma = app.get(PrismaService);
    await app.init();
  });

  afterAll(async () => {
    await prisma.user.deleteMany({
      where: { email: { endsWith: '@example.com', startsWith: tag } },
    });
    await app.close();
  });

  it('falls back without location, validates coordinate pairs, and saves location preferences', async () => {
    const registered = await registerAndVerify(app, {
      email,
      password,
      name: 'Weather User',
    });
    const accessToken = registered.body.accessToken as string;

    await request(app.getHttpServer())
      .get('/weather/current')
      .query({ latitude: 10.7769, longitude: 106.7009 })
      .expect(401);

    await request(app.getHttpServer())
      .get('/weather/reverse-geocode')
      .query({ latitude: 10.7769, longitude: 106.7009 })
      .expect(401);

    await request(app.getHttpServer())
      .get('/weather/forecast')
      .set('Authorization', `Bearer ${accessToken}`)
      .query({
        latitude: 10.7769,
        longitude: 106.7009,
        forecastDays: 30,
      })
      .expect(400);

    await request(app.getHttpServer())
      .get('/weather/me/current')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body.configured).toBe(false);
        expect(body.reason).toBe('LOCATION_MISSING');
        expect(body.greeting.title).toContain('Weather User');
      });

    await request(app.getHttpServer())
      .patch('/weather/me/location')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ latitude: 10.7769 })
      .expect(400)
      .expect(({ body }) => {
        expect(body.code).toBe(ErrorCode.VALIDATION_FAILED);
      });

    await request(app.getHttpServer())
      .patch('/weather/me/location')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        latitude: 10.7769,
        longitude: 106.7009,
        timezone: 'Asia/Ho_Chi_Minh',
        locationName: 'Ho Chi Minh City',
        reverseGeocode: false,
        weatherEnabled: false,
      })
      .expect(200)
      .expect(({ body }) => {
        expect(body.preferences.locationName).toBe('Ho Chi Minh City');
        expect(body.preferences.weatherEnabled).toBe(false);
        expect(body.weather.configured).toBe(false);
        expect(body.weather.reason).toBe('WEATHER_DISABLED');
      });

    await request(app.getHttpServer())
      .get('/weather/me/current')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body.configured).toBe(false);
        expect(body.reason).toBe('WEATHER_DISABLED');
      });
  });
});
