import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { MoodType, UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { ErrorCode } from './../src/common/errors/error-code';
import { HttpExceptionFilter } from './../src/common/errors/http-exception.filter';
import { PrismaService } from './../src/prisma/prisma.service';
import { registerAndVerify } from './helpers/register-and-verify';

describe('Mood Check-ins APIs (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  const tag = `e2e-mood-${Date.now()}`;
  const email = `${tag}@example.com`;
  const otherEmail = `${tag}-other@example.com`;
  const adminEmail = `${tag}-admin@example.com`;
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

  it('creates, lists, updates, protects, summarizes, and deletes mood check-ins', async () => {
    await request(app.getHttpServer())
      .get('/mood-checkins/options')
      .expect(200)
      .expect(({ body }) => {
        expect(body.length).toBeGreaterThanOrEqual(10);
        expect(body).toEqual(
          expect.arrayContaining([
            expect.objectContaining({
              mood: MoodType.STRESSED,
              label: 'Stress',
              iconKey: 'cat-stressed',
            }),
          ]),
        );
      });

    const registered = await registerAndVerify(app, {
      email,
      password,
      name: 'Mood User',
    });
    const accessToken = registered.body.accessToken as string;
    const userId = registered.body.user.id as string;

    const yesterday = new Date(Date.now() - 1000 * 60 * 60 * 24);
    await prisma.moodCheckin.create({
      data: {
        userId,
        mood: MoodType.NEUTRAL,
        intensity: 3,
        note: 'Yesterday setup',
        tags: ['setup'],
        createdAt: yesterday,
      },
    });

    await request(app.getHttpServer())
      .post('/mood-checkins/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        mood: MoodType.CALM,
        rawScore: 99,
        checkedAt: yesterday.toISOString(),
      })
      .expect(400)
      .expect(({ body }) => {
        expect(body.code).toBe(ErrorCode.VALIDATION_FAILED);
      });

    const created = await request(app.getHttpServer())
      .post('/mood-checkins/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        mood: MoodType.CALM,
        intensity: 4,
        note: 'Feeling lighter',
        tags: ['relax', 'finish'],
      })
      .expect(201)
      .expect(({ body }) => {
        expect(body.mood).toBe(MoodType.CALM);
        expect(body.intensity).toBe(4);
        expect(body.rawScore).toBe(10);
        expect(body.finalScore).toBe(10);
        expect(body.scoredAt).toBeTruthy();
        expect(body.tags).toEqual(['relax', 'finish']);
      });

    await request(app.getHttpServer())
      .get('/mood-checkins/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .query({ mood: MoodType.CALM, limit: 10 })
      .expect(200)
      .expect(({ body }) => {
        expect(body.total).toBe(1);
        expect(body.items).toHaveLength(1);
        expect(body.items[0].id).toBe(created.body.id);
      });

    await request(app.getHttpServer())
      .get('/mood-checkins/me/latest')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => expect(body.id).toBe(created.body.id));

    await request(app.getHttpServer())
      .patch(`/mood-checkins/${created.body.id}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ intensity: 5, note: 'Updated note' })
      .expect(200)
      .expect(({ body }) => {
        expect(body.intensity).toBe(5);
        expect(body.note).toBe('Updated note');
      });

    await request(app.getHttpServer())
      .get(`/mood-checkins/${created.body.id}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => expect(body.id).toBe(created.body.id));

    const otherRegistered = await registerAndVerify(app, {
      email: otherEmail,
      password,
      name: 'Other User',
    });
    const otherToken = otherRegistered.body.accessToken as string;

    await request(app.getHttpServer())
      .get(`/mood-checkins/${created.body.id}`)
      .set('Authorization', `Bearer ${otherToken}`)
      .expect(403)
      .expect(({ body }) => expect(body.code).toBe(ErrorCode.AUTH_FORBIDDEN));

    const admin = await prisma.user.create({
      data: {
        email: adminEmail,
        password: await bcrypt.hash(password, 12),
        role: UserRole.ADMIN,
        profile: { create: { displayName: 'Mood Admin' } },
        preferences: { create: {} },
      },
    });
    const adminLogin = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: admin.email, password })
      .expect(201);
    const adminToken = adminLogin.body.accessToken as string;

    await request(app.getHttpServer())
      .get(`/mood-checkins/user/${userId}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body.total).toBeGreaterThanOrEqual(2);
        expect(body.items.length).toBeGreaterThanOrEqual(2);
      });

    await request(app.getHttpServer())
      .get('/mood-checkins')
      .set('Authorization', `Bearer ${adminToken}`)
      .query({ limit: 10 })
      .expect(200)
      .expect(({ body }) => {
        expect(body.total).toBeGreaterThanOrEqual(2);
        expect(body.items.length).toBeGreaterThanOrEqual(2);
      });

    await request(app.getHttpServer())
      .get('/mood-checkins/me/stats')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body.total).toBe(2);
        expect(body.averageIntensity).toBe(4);
        expect(body.byMood).toEqual(
          expect.arrayContaining([
            { mood: MoodType.CALM, count: 1 },
            { mood: MoodType.NEUTRAL, count: 1 },
          ]),
        );
        expect(body.streak.current).toBeGreaterThanOrEqual(1);
        expect(body.streak.longest).toBeGreaterThanOrEqual(2);
      });

    await request(app.getHttpServer())
      .get('/mood-checkins/me/weekly-stats')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body.length).toBeGreaterThanOrEqual(1);
        expect(body[0].avgScore).toBeGreaterThanOrEqual(0);
        expect(body[0]).toHaveProperty('stressReducePct');
      });

    await prisma.weeklyMoodStat.deleteMany({ where: { userId } });
    await request(app.getHttpServer())
      .post('/mood-checkins/me/weekly-stats/recalculate')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ timezone: 'Asia/Ho_Chi_Minh' })
      .expect(201)
      .expect(({ body }) => {
        expect(body.timezone).toBe('Asia/Ho_Chi_Minh');
        expect(body.recalculatedCount).toBeGreaterThanOrEqual(1);
        expect(body.recalculatedWeeks[0]).toHaveProperty('avgScore');
      });

    await request(app.getHttpServer())
      .get('/mood-checkins/me/dashboard')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body.greeting.title).toBeTruthy();
        expect(body.options.length).toBeGreaterThanOrEqual(10);
        expect(body.currentMood.option.mood).toBe(MoodType.CALM);
        expect(body.distribution).toEqual(
          expect.arrayContaining([
            expect.objectContaining({ mood: MoodType.CALM, count: 1 }),
            expect.objectContaining({ mood: MoodType.NEUTRAL, count: 1 }),
          ]),
        );
        expect(body.recommendations.length).toBeGreaterThan(0);
      });

    await request(app.getHttpServer())
      .get('/mood-checkins/me/recommendations')
      .set('Authorization', `Bearer ${accessToken}`)
      .query({ mood: MoodType.STRESSED })
      .expect(200)
      .expect(({ body }) => {
        expect(body[0].type).toBe('BREATHING');
        expect(body).toEqual(
          expect.arrayContaining([
            expect.objectContaining({ type: 'MEDITATION' }),
            expect.objectContaining({ type: 'MUSIC' }),
          ]),
        );
      });

    await request(app.getHttpServer())
      .get(`/mood-checkins/user/${userId}/stats`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200)
      .expect(({ body }) => expect(body.total).toBe(2));

    const profile = await prisma.userProfile.findUniqueOrThrow({
      where: { userId },
    });
    expect(profile.totalMoodCheckins).toBe(2);
    expect(profile.longestStreak).toBeGreaterThanOrEqual(2);

    await request(app.getHttpServer())
      .delete(`/mood-checkins/${created.body.id}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);

    await request(app.getHttpServer())
      .get(`/mood-checkins/${created.body.id}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(404)
      .expect(({ body }) => {
        expect(body.code).toBe(ErrorCode.MOOD_CHECKIN_NOT_FOUND);
      });
  });

  it('requires auth and validates mood payloads', async () => {
    await request(app.getHttpServer()).get('/mood-checkins/me').expect(401);

    const registered = await registerAndVerify(app, {
      email: `${tag}-validation@example.com`,
      password,
      name: 'Bad',
    });

    await request(app.getHttpServer())
      .post('/mood-checkins/me')
      .set('Authorization', `Bearer ${registered.body.accessToken}`)
      .send({ mood: 'WILD', intensity: 6, tags: Array.from({ length: 11 }) })
      .expect(400)
      .expect(({ body }) => {
        expect(body.code).toBe(ErrorCode.VALIDATION_FAILED);
      });
  });

  it('builds daily mood analytics with previous-period comparison', async () => {
    const registered = await registerAndVerify(app, {
      email: `${tag}-analytics@example.com`,
      password,
      name: 'Analytics User',
    });
    const accessToken = registered.body.accessToken as string;
    const userId = registered.body.user.id as string;
    const now = new Date();
    const daysAgo = (days: number) =>
      new Date(now.getTime() - days * 1000 * 60 * 60 * 24);

    await prisma.moodCheckin.createMany({
      data: [
        {
          userId,
          mood: MoodType.STRESSED,
          intensity: 5,
          tags: ['previous'],
          createdAt: daysAgo(8),
        },
        {
          userId,
          mood: MoodType.ANXIOUS,
          intensity: 4,
          tags: ['previous'],
          createdAt: daysAgo(9),
        },
        {
          userId,
          mood: MoodType.CALM,
          intensity: 4,
          tags: ['current'],
          createdAt: daysAgo(1),
        },
        {
          userId,
          mood: MoodType.HAPPY,
          intensity: 5,
          tags: ['current'],
          createdAt: daysAgo(2),
        },
        {
          userId,
          mood: MoodType.NEUTRAL,
          intensity: 3,
          tags: ['current'],
          createdAt: daysAgo(3),
        },
      ],
    });

    await request(app.getHttpServer())
      .get('/mood-checkins/me/analytics')
      .set('Authorization', `Bearer ${accessToken}`)
      .query({ period: 'week', timezoneOffsetMinutes: 420 })
      .expect(200)
      .expect(({ body }) => {
        expect(body.summary.total).toBe(3);
        expect(body.summary.activeDays).toBe(3);
        expect(body.summary.positiveRate).toBe(67);
        expect(body.summary.stressRate).toBe(0);
        expect(body.previousSummary.total).toBe(2);
        expect(body.previousSummary.stressRate).toBe(100);
        expect(body.delta.stressReduction).toBe(100);
        expect(body.timeline).toHaveLength(7);
        expect(body.timeline).toEqual(
          expect.arrayContaining([
            expect.objectContaining({
              total: 1,
              dominantMood: MoodType.CALM,
            }),
          ]),
        );
        expect(body.insights).toEqual(
          expect.arrayContaining([expect.stringContaining('Stress giảm 100%')]),
        );
      });

    const admin = await prisma.user.create({
      data: {
        email: `${tag}-analytics-admin@example.com`,
        password: await bcrypt.hash(password, 12),
        role: UserRole.ADMIN,
        profile: { create: { displayName: 'Analytics Admin' } },
        preferences: { create: {} },
      },
    });
    const adminLogin = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: admin.email, password })
      .expect(201);

    await request(app.getHttpServer())
      .get(`/mood-checkins/user/${userId}/analytics`)
      .set('Authorization', `Bearer ${adminLogin.body.accessToken}`)
      .query({ period: 'week' })
      .expect(200)
      .expect(({ body }) => expect(body.summary.total).toBe(3));
  });

  it('groups analytics by the timezone offset for each historical check-in date', async () => {
    const registered = await registerAndVerify(app, {
      email: `${tag}-dst@example.com`,
      password,
      name: 'DST User',
    });
    const accessToken = registered.body.accessToken as string;
    const userId = registered.body.user.id as string;

    await prisma.userPreference.update({
      where: { userId },
      data: { timezone: 'America/New_York' },
    });
    await prisma.moodCheckin.create({
      data: {
        userId,
        mood: MoodType.CALM,
        intensity: 4,
        rawScore: 10,
        finalScore: 10,
        scoredAt: new Date('2026-01-02T04:30:00.000Z'),
        createdAt: new Date('2026-01-02T04:30:00.000Z'),
      },
    });

    await request(app.getHttpServer())
      .get('/mood-checkins/me/analytics')
      .set('Authorization', `Bearer ${accessToken}`)
      .query({
        period: 'custom',
        from: '2026-01-01T12:00:00.000Z',
        to: '2026-01-01T12:00:00.000Z',
        timezone: 'America/New_York',
        compare: false,
      })
      .expect(200)
      .expect(({ body }) => {
        expect(body.summary.total).toBe(1);
        expect(body.timeline).toEqual([
          expect.objectContaining({
            date: '2026-01-01',
            total: 1,
            dominantMood: MoodType.CALM,
          }),
        ]);
      });
  });

  describe('Voice Check-in & Mood Forecast', () => {
    it('analyzes voice text to draft a check-in', async () => {
      const registered = await registerAndVerify(app, {
        email: `${tag}-voice-check@example.com`,
        password,
        name: 'Voice Check User',
      });
      const accessToken = registered.body.accessToken as string;

      await request(app.getHttpServer())
        .post('/mood-checkins/voice')
        .set('Authorization', `Bearer ${accessToken}`)
        .send({ text: 'Mình thấy hơi mệt mỏi và uể oải sau ngày làm việc' })
        .expect(201)
        .expect(({ body }) => {
          expect(body.mood).toBe(MoodType.TIRED);
          expect(body.journalDraft).toContain('mệt mỏi');
          expect(body.tags).toContain('body:FATIGUE');
        });
    });

    it('returns a forecast message', async () => {
      const registered = await registerAndVerify(app, {
        email: `${tag}-forecast-check@example.com`,
        password,
        name: 'Forecast Check User',
      });
      const accessToken = registered.body.accessToken as string;

      await request(app.getHttpServer())
        .get('/analytics/me/mood-forecast')
        .set('Authorization', `Bearer ${accessToken}`)
        .expect(200)
        .expect(({ body }) => {
          expect(body.message).toBeDefined();
          expect(body.suggestedTime).toBeDefined();
        });
    });
  });
});
