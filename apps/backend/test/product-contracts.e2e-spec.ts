import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { CompanionType, UserRole } from '@prisma/client';
import { AppModule } from './../src/app.module';
import { HttpExceptionFilter } from './../src/common/errors/http-exception.filter';
import { PrismaService } from './../src/prisma/prisma.service';

describe('Product backend contracts (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  const tag = `e2e-contract-${Date.now()}`;
  const email = `${tag}@example.com`;
  const adminEmail = `${tag}-admin@example.com`;
  const password = 'secret123';
  let accessToken: string;
  let adminToken: string;
  let userId: string;

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

    const registered = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email, password, name: 'Contract User' })
      .expect(201);
    accessToken = registered.body.accessToken;
    userId = registered.body.user.id;

    const admin = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: adminEmail, password, name: 'Contract Admin' })
      .expect(201);
    await prisma.user.update({
      where: { id: admin.body.user.id },
      data: { role: UserRole.ADMIN },
    });
    const loggedInAdmin = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: adminEmail, password })
      .expect(201);
    adminToken = loggedInAdmin.body.accessToken;
  });

  afterAll(async () => {
    await prisma.companionAsset.deleteMany({
      where: { name: { startsWith: tag } },
    });
    await prisma.user.deleteMany({ where: { id: userId } });
    await prisma.user.deleteMany({
      where: { email: { startsWith: tag } },
    });
    await app.close();
  });

  it('exposes analytics, storage, provider, billing, and job contracts', async () => {
    await request(app.getHttpServer())
      .get('/analytics/contracts')
      .expect(200)
      .expect(({ body }) => {
        expect(body.weeklyMoodStat.weekStartsOn).toBe('MONDAY');
        expect(body.moodScore.effectiveScore).toContain('finalScore');
      });

    await request(app.getHttpServer())
      .get('/storage/cdn-strategy')
      .expect(200)
      .expect(({ body }) => {
        expect(body.provider).toBe('supabase');
        expect(body.pathConventions.companions).toContain('companions');
      });

    await request(app.getHttpServer())
      .get('/notifications/providers')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body.push.providers).toBeDefined();
        expect(body.email).toBeDefined();
      });

    await request(app.getHttpServer()).get('/billing/plans').expect(200);
    await request(app.getHttpServer())
      .get('/billing/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => expect(body.subscription.planName).toBe('FREE'));

    await request(app.getHttpServer())
      .post('/jobs/weekly-mood-stats/run')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({ userId, timezone: 'Asia/Ho_Chi_Minh' })
      .expect(201)
      .expect(({ body }) => {
        expect(body.job).toBe('weekly-mood-stats');
        expect(body.processedUsers).toBe(1);
      });
  });

  it('handles account lifecycle tokens without requiring a configured email provider', async () => {
    const verification = await request(app.getHttpServer())
      .post('/auth/me/email-verification')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(201);
    expect(verification.body.success).toBe(true);

    if (verification.body.delivery.devToken) {
      await request(app.getHttpServer())
        .post('/auth/email/verify')
        .send({ token: verification.body.delivery.devToken })
        .expect(201)
        .expect(({ body }) => {
          expect(body.success).toBe(true);
          expect(body.user.emailVerified).toBe(true);
        });
    }

    const reset = await request(app.getHttpServer())
      .post('/auth/password-reset/request')
      .send({ email })
      .expect(201);
    expect(reset.body.success).toBe(true);

    if (reset.body.delivery.devToken) {
      await request(app.getHttpServer())
        .post('/auth/password-reset/confirm')
        .send({ token: reset.body.delivery.devToken, password })
        .expect(201)
        .expect(({ body }) => expect(body.revokedSessions).toBe(true));

      const loggedIn = await request(app.getHttpServer())
        .post('/auth/login')
        .send({ email, password })
        .expect(201);
      accessToken = loggedIn.body.accessToken;
    }
  });

  it('registers push devices and manages notification read state', async () => {
    const device = await request(app.getHttpServer())
      .post('/notifications/me/devices')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        token: `${tag}-device-token`,
        platform: 'IOS',
        provider: 'FCM',
        deviceId: `${tag}-phone`,
        timezone: 'Asia/Ho_Chi_Minh',
      })
      .expect(201);

    await request(app.getHttpServer())
      .post('/notifications/me/test')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        title: 'Contract test',
        message: 'Hello from e2e',
        type: 'IN_APP',
      })
      .expect(201)
      .expect(({ body }) => {
        expect(body.notification.title).toBe('Contract test');
        expect(body.delivery.configured).toBe(true);
      });

    const list = await request(app.getHttpServer())
      .get('/notifications/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);
    expect(list.body.length).toBeGreaterThan(0);

    await request(app.getHttpServer())
      .patch(`/notifications/me/${list.body[0].id}/read`)
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => expect(body.isRead).toBe(true));

    await request(app.getHttpServer())
      .delete(`/notifications/me/devices/${device.body.id}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200);
  });

  it('switches companion personalization while preserving progress by default', async () => {
    await prisma.userProfile.update({
      where: { userId },
      data: { chineseZodiac: 'DRAGON' },
    });
    const asset = await prisma.companionAsset.create({
      data: {
        name: `${tag}-dragon-companion`,
        type: CompanionType.CAT,
        chineseZodiac: 'DRAGON',
        isActive: true,
      },
    });

    await request(app.getHttpServer())
      .patch('/user-companions/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ level: 5, affection: 44, energy: 77 })
      .expect(200);

    await request(app.getHttpServer())
      .patch('/user-companions/me/personalization-mode')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        personalizationMode: 'CHINESE_ZODIAC',
        preserveProgress: true,
      })
      .expect(200)
      .expect(({ body }) => {
        expect(body.companion.assetId).toBe(asset.id);
        expect(body.companion.level).toBe(5);
        expect(body.transition.preserveProgress).toBe(true);
      });
  });

  it('creates a pending checkout contract when no payment provider is wired', async () => {
    await request(app.getHttpServer())
      .post('/billing/me/checkout-session')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        planName: 'CHILL_PLUS',
        amount: 49000,
        currency: 'VND',
        provider: 'STRIPE',
      })
      .expect(201)
      .expect(({ body }) => {
        expect(body.payment.status).toBe('PENDING');
        expect(body.checkout.status).toBeDefined();
      });
  });

  it('soft deletes and anonymizes an account when requested by the owner', async () => {
    const deleteEmail = `${tag}-delete@example.com`;
    const registered = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: deleteEmail, password, name: 'Delete Me' })
      .expect(201);

    await request(app.getHttpServer())
      .delete('/auth/me')
      .set('Authorization', `Bearer ${registered.body.accessToken}`)
      .send({ mode: 'SOFT', password })
      .expect(200)
      .expect(({ body }) => {
        expect(body.success).toBe(true);
        expect(body.anonymized).toBe(true);
      });

    const deletedUser = await prisma.user.findUnique({
      where: { id: registered.body.user.id },
    });
    expect(deletedUser?.isActive).toBe(false);
    expect(deletedUser?.deletedAt).toBeTruthy();
    expect(deletedUser?.email).toContain('deleted-');

    await prisma.user.delete({ where: { id: registered.body.user.id } });
  });
});
