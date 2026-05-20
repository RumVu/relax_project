import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { MoodType } from '@prisma/client';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { HttpExceptionFilter } from './../src/common/errors/http-exception.filter';
import { PrismaService } from './../src/prisma/prisma.service';

describe('Relax Activities APIs (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  const tag = `e2e-relax-${Date.now()}`;
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
    const users = await prisma.user.findMany({
      where: { email: { endsWith: '@example.com', startsWith: tag } },
      select: { id: true },
    });
    const userIds = users.map((user) => user.id);

    await prisma.appEvent.deleteMany({
      where: {
        userId: { in: userIds },
        type: { in: ['RELAX_SESSION_STARTED', 'RELAX_SESSION_FINISHED'] },
      },
    });
    await prisma.user.deleteMany({
      where: { id: { in: userIds } },
    });
    await app.close();
  });

  it('serves activity options and records the start/finish popup flow', async () => {
    await request(app.getHttpServer())
      .get('/relax-activities')
      .expect(200)
      .expect(({ body }) => {
        expect(body).toEqual(
          expect.arrayContaining([
            expect.objectContaining({ type: 'MUSIC', title: 'Nhạc' }),
            expect.objectContaining({
              type: 'BREATHING',
              title: 'Hít thở không khí',
            }),
            expect.objectContaining({
              type: 'MEDITATION',
              title: 'Thiền định',
            }),
          ]),
        );
      });

    const registered = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email, password, name: 'Relax User' })
      .expect(201);
    const accessToken = registered.body.accessToken as string;
    const userId = registered.body.user.id as string;
    const startedAt = new Date(Date.now() - 25 * 60 * 1000);

    await request(app.getHttpServer())
      .post('/relax-activities/sessions/start')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        activityType: 'MUSIC',
        startedAt: startedAt.toISOString(),
      })
      .expect(400);

    const started = await request(app.getHttpServer())
      .post('/relax-activities/sessions/start')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        activityType: 'MUSIC',
        title: 'Lo-fi Chill',
        moodBefore: MoodType.STRESSED,
      })
      .expect(201)
      .expect(({ body }) => {
        expect(body.status).toBe('STARTED');
        expect(body.activityType).toBe('MUSIC');
        expect(body.id).toBeTruthy();
      });

    await prisma.relaxSession.update({
      where: { id: started.body.id },
      data: { startedAt },
    });

    await request(app.getHttpServer())
      .post(`/relax-activities/sessions/${started.body.id}/finish`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        moodAfter: MoodType.CALM,
        reliefLevel: 4,
        note: 'Nhẹ hơn nhiều',
      })
      .expect(201)
      .expect(({ body }) => {
        expect(body.status).toBe('FINISHED');
        expect(body.stressReliefPercent).toBe(80);
        expect(body.postCheckin.title).toBe('Mức độ giảm tải');
        expect(body.nextSuggestion).toBeTruthy();
      });

    const tamperedSession = await request(app.getHttpServer())
      .post('/relax-activities/sessions/start')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ activityType: 'BREATHING' })
      .expect(201);

    await request(app.getHttpServer())
      .post(`/relax-activities/sessions/${tamperedSession.body.id}/finish`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        moodAfter: MoodType.CALM,
        durationSeconds: 9999,
        endedAt: new Date().toISOString(),
      })
      .expect(400);

    await request(app.getHttpServer())
      .get('/relax-activities/me/sessions')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body).toHaveLength(1);
        expect(body[0].activityType).toBe('MUSIC');
        expect(body[0].durationSeconds).toBeGreaterThan(0);
      });

    await request(app.getHttpServer())
      .get('/relax-activities/me/stats')
      .set('Authorization', `Bearer ${accessToken}`)
      .query({ period: 'week', timezoneOffsetMinutes: 420 })
      .expect(200)
      .expect(({ body }) => {
        expect(body.totalSessions).toBe(1);
        expect(body.totalDurationSeconds).toBeGreaterThan(0);
        expect(body.favoriteActivities[0].type).toBe('MUSIC');
        expect(body.recentMoments).toHaveLength(1);
        expect(body.timeline).toHaveLength(7);
        expect(body.relief.averageStressRelief).toBe(80);
      });

    const finishMoodCheckin = await prisma.moodCheckin.findFirst({
      where: {
        userId,
        tags: { has: 'relax-finish' },
      },
    });
    expect(finishMoodCheckin?.mood).toBe(MoodType.CALM);
    expect(finishMoodCheckin?.rawScore).toBe(90);
    expect(finishMoodCheckin?.finalScore).toBe(10);
    expect(finishMoodCheckin?.scoredAt).toBeTruthy();
  });

  it('requires auth before starting sessions', async () => {
    await request(app.getHttpServer())
      .post('/relax-activities/sessions/start')
      .send({ activityType: 'MUSIC' })
      .expect(401);
  });
});
