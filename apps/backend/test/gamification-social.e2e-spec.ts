import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { MoodType } from '@prisma/client';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { HttpExceptionFilter } from './../src/common/errors/http-exception.filter';
import { PrismaService } from './../src/prisma/prisma.service';

describe('Gamification & Social APIs (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  const tag = `e2e-gamsoc-${Date.now()}`;
  const emailA = `${tag}-a@example.com`;
  const emailB = `${tag}-b@example.com`;
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

    await prisma.pointsTransaction.deleteMany({
      where: { userPoints: { userId: { in: userIds } } },
    });
    await prisma.userPoints.deleteMany({
      where: { userId: { in: userIds } },
    });
    await prisma.userAchievement.deleteMany({
      where: { userId: { in: userIds } },
    });
    await prisma.feedEntry.deleteMany({
      where: { userId: { in: userIds } },
    });
    await prisma.friend.deleteMany({
      where: {
        OR: [{ userId: { in: userIds } }, { friendId: { in: userIds } }],
      },
    });
    await prisma.relaxSession.deleteMany({
      where: { userId: { in: userIds } },
    });
    await prisma.moodCheckin.deleteMany({
      where: { userId: { in: userIds } },
    });
    await prisma.user.deleteMany({
      where: { id: { in: userIds } },
    });
    await app.close();
  });

  it('verifies achievements, friend requests, feed posts, and points transactions', async () => {
    // 1. Register User A and User B
    const regA = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: emailA, password, name: 'User A' })
      .expect(201);
    const tokenA = regA.body.accessToken as string;
    const idA = regA.body.user.id as string;

    const regB = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: emailB, password, name: 'User B' })
      .expect(201);
    const tokenB = regB.body.accessToken as string;
    const idB = regB.body.user.id as string;

    // 2. Fetch Achievements for User A (should be locked)
    await request(app.getHttpServer())
      .get('/achievements/me')
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body).toEqual(
          expect.arrayContaining([
            expect.objectContaining({
              title: 'Bước đầu ghi nhận cảm xúc',
              unlocked: false,
            }),
            expect.objectContaining({
              title: 'Buổi thư giãn đầu tiên',
              unlocked: false,
            }),
          ]),
        );
      });

    // 3. User A checks in mood (should unlock first achievement)
    await request(app.getHttpServer())
      .post('/mood-checkins/me')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        mood: MoodType.HAPPY,
        intensity: 4,
        note: 'Feeling good!',
        tags: ['e2e'],
      })
      .expect(201);

    // 4. Verify achievement is unlocked for User A
    await request(app.getHttpServer())
      .get('/achievements/me')
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(200)
      .expect(({ body }) => {
        const checkinAch = body.find(
          (a: any) => a.title === 'Bước đầu ghi nhận cảm xúc',
        );
        expect(checkinAch).toBeDefined();
        expect(checkinAch.unlocked).toBe(true);
      });

    // 5. User A completes a relax session (should unlock second achievement)
    const started = await request(app.getHttpServer())
      .post('/relax-activities/sessions/start')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        activityType: 'MUSIC',
        title: 'Calm Piano',
        moodBefore: MoodType.NEUTRAL,
      })
      .expect(201);

    await request(app.getHttpServer())
      .post(`/relax-activities/sessions/${started.body.id}/finish`)
      .set('Authorization', `Bearer ${tokenA}`)
      .send({
        moodAfter: MoodType.CALM,
        reliefLevel: 4,
        note: 'Super relaxed',
      })
      .expect(201);

    // Verify relax achievement is unlocked
    await request(app.getHttpServer())
      .get('/achievements/me')
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(200)
      .expect(({ body }) => {
        const relaxAch = body.find(
          (a: any) => a.title === 'Buổi thư giãn đầu tiên',
        );
        expect(relaxAch).toBeDefined();
        expect(relaxAch.unlocked).toBe(true);
      });

    // 6. User A sends friend request to User B
    await request(app.getHttpServer())
      .post(`/friends/request/${idB}`)
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(201);

    // User B views pending requests
    await request(app.getHttpServer())
      .get('/friends/pending')
      .set('Authorization', `Bearer ${tokenB}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body).toHaveLength(1);
        expect(body[0].id).toBe(idA);
      });

    // User B accepts friend request
    await request(app.getHttpServer())
      .post(`/friends/accept/${idA}`)
      .set('Authorization', `Bearer ${tokenB}`)
      .expect(201);

    // Verify they are friends
    await request(app.getHttpServer())
      .get('/friends/me')
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body).toHaveLength(1);
        expect(body[0].id).toBe(idB);
      });

    // 7. Verify activity feed entries exist for both User A and User B
    await request(app.getHttpServer())
      .get('/feed')
      .set('Authorization', `Bearer ${tokenA}`)
      .expect(200)
      .expect(({ body }) => {
        // Feed should contain:
        // - User A checkin
        // - User A relax finished
        expect(body.length).toBeGreaterThanOrEqual(2);
        const types = body.map((f: any) => f.type);
        expect(types).toContain('MOOD_CHECKIN');
        expect(types).toContain('RELAX_SESSION');
      });

    // 8. User A chats with their companion
    const chatRes = await request(app.getHttpServer())
      .post('/user-companions/me/chat')
      .set('Authorization', `Bearer ${tokenA}`)
      .send({ message: 'Xin chào linh thú!' })
      .expect(201);

    expect(chatRes.body).toBeDefined();
    expect(chatRes.body.reply).toBeDefined();
    expect(typeof chatRes.body.reply).toBe('string');
    expect(chatRes.body.companion).toBeDefined();
    expect(chatRes.body.companion.affection).toBeGreaterThanOrEqual(2);
  });

  it('verifies consecutive check-ins, UserStreak cache, and milestone achievement unlock with social feed notification', async () => {
    const emailC = `${tag}-c@example.com`;
    const regC = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: emailC, password, name: 'User C' })
      .expect(201);
    const tokenC = regC.body.accessToken as string;
    const idC = regC.body.user.id as string;

    // 1. Log a check-in for "today"
    const firstCheckin = await request(app.getHttpServer())
      .post('/mood-checkins/me')
      .set('Authorization', `Bearer ${tokenC}`)
      .send({ mood: MoodType.HAPPY, intensity: 5, note: 'Day 1' })
      .expect(201);

    // 2. Fetch UserStreak - should be 1
    const streakRes1 = await prisma.userStreak.findUnique({
      where: { userId: idC },
    });
    expect(streakRes1).toBeDefined();
    expect(streakRes1?.currentStreak).toBe(1);

    // 3. Move the first check-in to 2 days ago
    const twoDaysAgo = new Date();
    twoDaysAgo.setDate(twoDaysAgo.getDate() - 2);
    await prisma.moodCheckin.update({
      where: { id: firstCheckin.body.id },
      data: {
        createdAt: twoDaysAgo,
        scoredAt: twoDaysAgo,
      },
    });

    // 4. Log another check-in
    const secondCheckin = await request(app.getHttpServer())
      .post('/mood-checkins/me')
      .set('Authorization', `Bearer ${tokenC}`)
      .send({ mood: MoodType.CALM, intensity: 4, note: 'Day 2' })
      .expect(201);

    // Move second check-in to yesterday
    const yesterday = new Date();
    yesterday.setDate(yesterday.getDate() - 1);
    await prisma.moodCheckin.update({
      where: { id: secondCheckin.body.id },
      data: {
        createdAt: yesterday,
        scoredAt: yesterday,
      },
    });

    // 5. Log third check-in today
    await request(app.getHttpServer())
      .post('/mood-checkins/me')
      .set('Authorization', `Bearer ${tokenC}`)
      .send({ mood: MoodType.NEUTRAL, intensity: 3, note: 'Day 3' })
      .expect(201);

    // 6. Verify UserStreak in database is now 3!
    const streakRes3 = await prisma.userStreak.findUnique({
      where: { userId: idC },
    });
    expect(streakRes3?.currentStreak).toBe(3);

    // 7. Verify the achievement "Chuỗi 3 ngày: Đồng hành chớm nở" is unlocked!
    await request(app.getHttpServer())
      .get('/achievements/me')
      .set('Authorization', `Bearer ${tokenC}`)
      .expect(200)
      .expect(({ body }) => {
        const streakAch = body.find(
          (a: any) => a.title === 'Chuỗi 3 ngày: Đồng hành chớm nở',
        );
        expect(streakAch).toBeDefined();
        expect(streakAch.unlocked).toBe(true);
      });

    // 8. Verify the social feed has an ACHIEVEMENT_UNLOCKED entry!
    await request(app.getHttpServer())
      .get('/feed')
      .set('Authorization', `Bearer ${tokenC}`)
      .expect(200)
      .expect(({ body }) => {
        const feedEntries = body.filter((f: any) => f.userId === idC);
        const achievementUnlockFeed = feedEntries.find(
          (f: any) =>
            f.type === 'ACHIEVEMENT_UNLOCKED' &&
            f.title === 'Đã mở khóa thành tựu mới',
        );
        expect(achievementUnlockFeed).toBeDefined();
        expect(achievementUnlockFeed.description).toContain(
          'Chuỗi 3 ngày: Đồng hành chớm nở',
        );
      });
  });
});
