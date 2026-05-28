import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { ThemeMode, UserRole } from '@prisma/client';
import { AppModule } from './../src/app.module';
import { HttpExceptionFilter } from './../src/common/errors/http-exception.filter';
import { PrismaService } from './../src/prisma/prisma.service';

/**
 * Dedicated coverage for the user-profiles, user-preferences and analytics
 * modules. Existing wellness-stack.e2e-spec only touches /analytics/me/overview
 * tangentially; this file asserts the dedicated contracts and admin-vs-self
 * authorisation rules.
 */
describe('User account + analytics APIs (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  const tag = `e2e-account-${Date.now()}`;
  const password = 'Password123!';
  const adminEmail = `${tag}-admin@example.com`;
  const userEmail = `${tag}-user@example.com`;
  let adminToken: string;
  let userToken: string;
  let userId: string;

  const authed = (token: string) => (req: request.Test) =>
    req.set('Authorization', `Bearer ${token}`);

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

    // Admin user
    const adminReg = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: adminEmail, password, name: `${tag}-admin` })
      .expect(201);
    await prisma.user.update({
      where: { id: adminReg.body.user.id },
      data: { role: UserRole.ADMIN },
    });
    const adminLogin = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: adminEmail, password })
      .expect(201);
    adminToken = adminLogin.body.accessToken;

    // Plain user
    const userReg = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: userEmail, password, name: `${tag}-user` })
      .expect(201);
    userId = userReg.body.user.id;
    userToken = userReg.body.accessToken;
  });

  afterAll(async () => {
    await prisma.user.deleteMany({
      where: { email: { startsWith: tag } },
    });
    await app.close();
  });

  // ---------------------------------------------------------------------------
  // User profiles
  // ---------------------------------------------------------------------------
  describe('user-profiles', () => {
    it('rejects anonymous access', async () => {
      await request(app.getHttpServer())
        .get('/user-profiles/me/profile')
        .expect(401);
    });

    it('returns the current user profile for /me/profile', async () => {
      await authed(userToken)(
        request(app.getHttpServer()).get('/user-profiles/me/profile'),
      )
        .expect(200)
        .expect(({ body }) => {
          expect(body).toBeTruthy();
          expect(typeof body).toBe('object');
        });
    });

    it('upserts the current user profile (PATCH /me/profile)', async () => {
      await authed(userToken)(
        request(app.getHttpServer()).patch('/user-profiles/me/profile'),
      )
        .send({ displayName: `${tag}-display`, bio: 'Updated bio' })
        .expect(200)
        .expect(({ body }) => {
          expect(body.displayName).toBe(`${tag}-display`);
          expect(body.bio).toBe('Updated bio');
        });
    });

    it('forbids non-admin from reading another user profile', async () => {
      await authed(userToken)(
        request(app.getHttpServer()).get(`/user-profiles/${userId}`),
      ).expect(403);
    });

    it('allows admin to read and upsert profile by userId', async () => {
      await authed(adminToken)(
        request(app.getHttpServer()).get(`/user-profiles/${userId}`),
      )
        .expect(200)
        .expect(({ body }) => expect(body.displayName).toBe(`${tag}-display`));

      await authed(adminToken)(
        request(app.getHttpServer()).patch(`/user-profiles/${userId}`),
      )
        .send({ bio: 'Admin-set bio' })
        .expect(200)
        .expect(({ body }) => expect(body.bio).toBe('Admin-set bio'));
    });
  });

  // ---------------------------------------------------------------------------
  // User preferences
  // ---------------------------------------------------------------------------
  describe('user-preferences', () => {
    it('rejects anonymous /me/preferences', async () => {
      await request(app.getHttpServer())
        .get('/user-preferences/me/preferences')
        .expect(401);
    });

    it('returns the current user preferences', async () => {
      await authed(userToken)(
        request(app.getHttpServer()).get('/user-preferences/me/preferences'),
      )
        .expect(200)
        .expect(({ body }) => expect(body).toBeTruthy());
    });

    it('upserts the current user preferences with valid payload', async () => {
      await authed(userToken)(
        request(app.getHttpServer()).patch('/user-preferences/me/preferences'),
      )
        .send({
          language: 'vi',
          timezone: 'Asia/Ho_Chi_Minh',
          themeMode: ThemeMode.DARK,
          enableSound: false,
          pushNotificationsEnabled: true,
          bubbleIntervalSeconds: 30,
        })
        .expect(200)
        .expect(({ body }) => {
          expect(body.language).toBe('vi');
          expect(body.timezone).toBe('Asia/Ho_Chi_Minh');
          expect(body.themeMode).toBe(ThemeMode.DARK);
          expect(body.enableSound).toBe(false);
          expect(body.pushNotificationsEnabled).toBe(true);
          expect(body.bubbleIntervalSeconds).toBe(30);
        });
    });

    it('rejects invalid latitude/longitude payloads', async () => {
      await authed(userToken)(
        request(app.getHttpServer()).patch('/user-preferences/me/preferences'),
      )
        .send({ latitude: 200, longitude: -500 })
        .expect(400);
    });

    it('forbids non-admin from reading another user preferences', async () => {
      await authed(userToken)(
        request(app.getHttpServer()).get(`/user-preferences/${userId}`),
      ).expect(403);
    });

    it('allows admin to upsert preferences for any user', async () => {
      await authed(adminToken)(
        request(app.getHttpServer()).patch(`/user-preferences/${userId}`),
      )
        .send({ language: 'en', emailNotificationsEnabled: false })
        .expect(200)
        .expect(({ body }) => {
          expect(body.language).toBe('en');
          expect(body.emailNotificationsEnabled).toBe(false);
        });
    });
  });

  // ---------------------------------------------------------------------------
  // Analytics
  // ---------------------------------------------------------------------------
  describe('analytics', () => {
    it('rejects anonymous /analytics/contracts', async () => {
      await request(app.getHttpServer())
        .get('/analytics/contracts')
        .expect(401);
    });

    it('serves the chart/card contracts to an authenticated user', async () => {
      await authed(userToken)(
        request(app.getHttpServer()).get('/analytics/contracts'),
      )
        .expect(200)
        .expect(({ body }) => {
          expect(body.moodScore).toBeTruthy();
          expect(body.moodScore.scale).toBe('0-100');
          expect(body.weeklyMoodStat).toBeTruthy();
          expect(Array.isArray(body.dashboardCards)).toBe(true);
          expect(body.dashboardCards.length).toBeGreaterThan(0);
          expect(body.charts).toBeTruthy();
          expect(body.charts.moodTimeline).toBeTruthy();
        });
    });

    it('returns an aggregate overview for /analytics/me/overview', async () => {
      await authed(userToken)(
        request(app.getHttpServer()).get('/analytics/me/overview'),
      )
        .expect(200)
        .expect(({ body }) => {
          // Shape: { period, timezone, mood, journals, relax, companion, summaryCards }
          expect(body.period).toBeTruthy();
          expect(body.timezone).toBeTruthy();
          expect(body.mood).toBeTruthy();
          expect(body.journals).toBeTruthy();
          expect(body.relax).toBeTruthy();
          expect(body.companion).toBeTruthy();
          expect(body.summaryCards).toBeTruthy();
          expect(typeof body.summaryCards.totalJournals).toBe('number');
        });
    });
  });
});
