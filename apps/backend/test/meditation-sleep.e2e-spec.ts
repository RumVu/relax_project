import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { MoodType } from '@prisma/client';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { HttpExceptionFilter } from './../src/common/errors/http-exception.filter';
import { PrismaService } from './../src/prisma/prisma.service';

describe('Meditations & Sleep APIs (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  const tag = `e2e-medsleep-${Date.now()}`;
  const email = `${tag}@example.com`;
  const password = 'Secret123!x';
  let guideId: string;

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

    // Seed a dummy MeditationGuide
    const guide = await prisma.meditationGuide.create({
      data: {
        title: 'Thiền tỉnh thức ban mai',
        description: 'Tập trung hơi thở lúc bình minh',
        duration: 10,
        focusArea: 'Mindfulness',
        difficulty: 'BEGINNER',
        instructor: 'Thầy Minh',
        isActive: true,
      },
    });
    guideId = guide.id;
  });

  afterAll(async () => {
    const users = await prisma.user.findMany({
      where: { email: { endsWith: '@example.com', startsWith: tag } },
      select: { id: true },
    });
    const userIds = users.map((u) => u.id);

    await prisma.meditationSession.deleteMany({
      where: { userId: { in: userIds } },
    });
    await prisma.sleepSession.deleteMany({
      where: { userId: { in: userIds } },
    });
    await prisma.meditationGuide.delete({
      where: { id: guideId },
    });
    await prisma.user.deleteMany({
      where: { id: { in: userIds } },
    });
    await app.close();
  });

  it('runs meditation and sleep session tracking cycles', async () => {
    // 1. Register test user
    const regRes = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email, password, name: 'Med Sleep User' })
      .expect(201);
    const token = regRes.body.accessToken as string;

    // 2. Fetch active meditation guides
    await request(app.getHttpServer())
      .get('/meditations/guides')
      .set('Authorization', `Bearer ${token}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body).toBeInstanceOf(Array);
        const guideObj = body.find((g: any) => g.id === guideId);
        expect(guideObj).toBeDefined();
        expect(guideObj.title).toBe('Thiền tỉnh thức ban mai');
      });

    // 3. Log a meditation session
    const startedAt = new Date(Date.now() - 600000).toISOString(); // 10 min ago
    const endedAt = new Date().toISOString();
    const medSessionRes = await request(app.getHttpServer())
      .post('/meditations/sessions')
      .set('Authorization', `Bearer ${token}`)
      .send({
        guideId,
        duration: 10,
        startedAt,
        endedAt,
        focusArea: 'Mindfulness',
        mood: MoodType.CALM,
        quality: 8,
        notes: 'Cảm thấy rất thanh tịnh.',
      })
      .expect(201);

    expect(medSessionRes.body.id).toBeDefined();
    expect(medSessionRes.body.duration).toBe(10);
    expect(medSessionRes.body.guideId).toBe(guideId);

    // 4. Get meditation sessions history
    await request(app.getHttpServer())
      .get('/meditations/sessions/me')
      .set('Authorization', `Bearer ${token}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body).toHaveLength(1);
        expect(body[0].id).toBe(medSessionRes.body.id);
        expect(body[0].guide.title).toBe('Thiền tỉnh thức ban mai');
      });

    // 5. Log a sleep session
    const sleepStarted = new Date(Date.now() - 28800000).toISOString(); // 8 hours ago
    const sleepEnded = new Date().toISOString();
    const sleepRes = await request(app.getHttpServer())
      .post('/sleep/sessions')
      .set('Authorization', `Bearer ${token}`)
      .send({
        startedAt: sleepStarted,
        endedAt: sleepEnded,
        quality: 9,
        note: 'Ngủ rất ngon và sâu giấc.',
      })
      .expect(201);

    expect(sleepRes.body.id).toBeDefined();
    expect(sleepRes.body.quality).toBe(9);

    // 6. Get sleep history
    await request(app.getHttpServer())
      .get('/sleep/sessions/me')
      .set('Authorization', `Bearer ${token}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body).toHaveLength(1);
        expect(body[0].id).toBe(sleepRes.body.id);
        expect(body[0].quality).toBe(9);
      });
  });
});
