import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { MoodType } from '@prisma/client';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { ErrorCode } from './../src/common/errors/error-code';
import { HttpExceptionFilter } from './../src/common/errors/http-exception.filter';
import { PrismaService } from './../src/prisma/prisma.service';
import { registerAndVerify } from './helpers/register-and-verify';

describe('Wellness stack APIs (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  const tag = `e2e-stack-${Date.now()}`;
  const email = `${tag}@example.com`;
  const otherEmail = `${tag}-other@example.com`;
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
    if (!prisma) {
      return;
    }

    const users = await prisma.user.findMany({
      where: { email: { endsWith: '@example.com', startsWith: tag } },
      select: { id: true },
    });
    const userIds = users.map((user) => user.id);
    await prisma.appEvent.deleteMany({ where: { userId: { in: userIds } } });
    await prisma.user.deleteMany({ where: { id: { in: userIds } } });
    await app.close();
  });

  it('links journals, companion, relax sessions, mood check-ins, and analytics overview', async () => {
    const registered = await registerAndVerify(app, {
      email,
      password,
      name: 'Stack User',
    });
    const accessToken = registered.body.accessToken as string;

    await request(app.getHttpServer())
      .post('/mood-checkins/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ mood: MoodType.STRESSED, intensity: 5, tags: ['stack'] })
      .expect(201);

    const journal = await request(app.getHttpServer())
      .post('/journals/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        title: 'Một chút nhẹ lòng',
        content: 'Hôm nay hơi căng nhưng đã ổn hơn.',
        mood: MoodType.CALM,
        tags: ['relax', 'stack'],
        isFavorite: true,
      })
      .expect(201)
      .expect(({ body }) => {
        expect(body.mood).toBe(MoodType.CALM);
        expect(body.tags).toEqual(['relax', 'stack']);
      });

    await request(app.getHttpServer())
      .get('/journals/me/stats')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body.total).toBe(1);
        expect(body.favorites).toBe(1);
      });

    await request(app.getHttpServer())
      .patch('/user-companions/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ name: 'Thì Ai', mood: 'HAPPY', affection: 20 })
      .expect(200)
      .expect(({ body }) => {
        expect(body.name).toBe('Thì Ai');
        expect(body.mood).toBe('HAPPY');
      });

    await request(app.getHttpServer())
      .post('/user-companions/me/interactions')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ type: 'PET', metadata: { source: 'e2e' } })
      .expect(201)
      .expect(({ body }) => {
        expect(body.interaction.type).toBe('PET');
        expect(body.companion.affection).toBeGreaterThanOrEqual(24);
      });

    const session = await request(app.getHttpServer())
      .post('/relax-sessions/start')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ activityType: 'JOURNAL', moodBefore: MoodType.STRESSED })
      .expect(201);

    await prisma.relaxSession.update({
      where: { id: session.body.id },
      data: { startedAt: new Date(Date.now() - 15 * 60 * 1000) },
    });

    await request(app.getHttpServer())
      .post(`/relax-sessions/${session.body.id}/finish`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        moodAfter: MoodType.CALM,
        reliefLevel: 5,
      })
      .expect(201)
      .expect(({ body }) => {
        expect(body.status).toBe('FINISHED');
        expect(body.stressReliefPercent).toBe(100);
      });

    await request(app.getHttpServer())
      .get('/relax-sessions/me/stats')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body.totalSessions).toBe(1);
        expect(body.totalDurationSeconds).toBeGreaterThan(0);
      });

    await request(app.getHttpServer())
      .get('/analytics/me/overview')
      .set('Authorization', `Bearer ${accessToken}`)
      .query({ period: 'week', timezoneOffsetMinutes: 420 })
      .expect(200)
      .expect(({ body }) => {
        expect(body.mood.summary.total).toBeGreaterThanOrEqual(2);
        expect(body.journals.total).toBe(1);
        expect(body.relax.totalSessions).toBe(1);
        expect(body.companion.totalInteractions).toBe(1);
        expect(body.summaryCards.totalJournals).toBe(1);
      });

    const other = await registerAndVerify(app, {
      email: otherEmail,
      password,
      name: 'Other User',
    });

    await request(app.getHttpServer())
      .get(`/journals/${journal.body.id}`)
      .set('Authorization', `Bearer ${other.body.accessToken}`)
      .expect(403)
      .expect(({ body }) => {
        expect(body.code).toBe(ErrorCode.AUTH_FORBIDDEN);
      });
  });
});
