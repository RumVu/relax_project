import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { UserRole } from '@prisma/client';
import { AppModule } from './../src/app.module';
import { HttpExceptionFilter } from './../src/common/errors/http-exception.filter';
import { PrismaService } from './../src/prisma/prisma.service';

describe('Push devices, notifications and sessions (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  const tag = `e2e-notif-${Date.now()}`;
  const adminEmail = `${tag}-admin@example.com`;
  const userEmail = `${tag}-user@example.com`;
  const password = 'Password123!';
  let adminToken: string;
  let userToken: string;
  let userId: string;

  const auth = (token: string) => `Bearer ${token}`;

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

    const registeredAdmin = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: adminEmail, password, name: `${tag}-admin` })
      .expect(201);
    await prisma.user.update({
      where: { id: registeredAdmin.body.user.id },
      data: { role: UserRole.ADMIN },
    });
    adminToken = (
      await request(app.getHttpServer())
        .post('/auth/login')
        .send({ email: adminEmail, password })
        .expect(201)
    ).body.accessToken;

    const registeredUser = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: userEmail, password, name: `${tag}-user` })
      .expect(201);
    userToken = registeredUser.body.accessToken;
    userId = registeredUser.body.user.id;
  });

  afterAll(async () => {
    await prisma.user.deleteMany({
      where: { email: { startsWith: tag } },
    });
    await app.close();
  });

  describe('Push device lifecycle', () => {
    let deviceId: string;

    it('registers a push device', async () => {
      await request(app.getHttpServer())
        .post('/notifications/me/devices')
        .set('Authorization', auth(userToken))
        .send({
          token: `${tag}-device-token`,
          platform: 'ANDROID',
          provider: 'FCM',
          deviceName: 'E2E Pixel',
        })
        .expect(201)
        .expect(({ body }) => {
          expect(body.id).toBeTruthy();
          deviceId = body.id;
        });
    });

    it('lists the registered device', async () => {
      await request(app.getHttpServer())
        .get('/notifications/me/devices')
        .set('Authorization', auth(userToken))
        .expect(200)
        .expect(({ body }) => {
          expect(
            body.some((device: { id: string }) => device.id === deviceId),
          ).toBe(true);
        });
    });

    it('removes the device and no longer lists it', async () => {
      await request(app.getHttpServer())
        .delete(`/notifications/me/devices/${deviceId}`)
        .set('Authorization', auth(userToken))
        .expect(200);

      await request(app.getHttpServer())
        .get('/notifications/me/devices')
        .set('Authorization', auth(userToken))
        .expect(200)
        .expect(({ body }) => {
          expect(
            body.some((device: { id: string }) => device.id === deviceId),
          ).toBe(false);
        });
    });

    it('requires authentication to register a device', async () => {
      await request(app.getHttpServer())
        .post('/notifications/me/devices')
        .send({ token: 'x', platform: 'ANDROID' })
        .expect(401);
    });
  });

  describe('Notification read flow', () => {
    let notificationId: string;

    it('creates a test notification and counts it as unread', async () => {
      await request(app.getHttpServer())
        .post('/notifications/me/test')
        .set('Authorization', auth(userToken))
        .send({ title: `${tag} hello`, message: 'e2e notification' })
        .expect(201)
        .expect(({ body }) => {
          expect(body.notification.id).toBeTruthy();
          notificationId = body.notification.id;
        });

      await request(app.getHttpServer())
        .get('/notifications/me/unread-count')
        .set('Authorization', auth(userToken))
        .expect(200)
        .expect(({ body }) => {
          expect(body.count).toBeGreaterThanOrEqual(1);
        });
    });

    it('marks one and then all notifications as read', async () => {
      await request(app.getHttpServer())
        .patch(`/notifications/me/${notificationId}/read`)
        .set('Authorization', auth(userToken))
        .expect(200);

      await request(app.getHttpServer())
        .patch('/notifications/me/read-all')
        .set('Authorization', auth(userToken))
        .expect(200);

      await request(app.getHttpServer())
        .get('/notifications/me/unread-count')
        .set('Authorization', auth(userToken))
        .expect(200)
        .expect(({ body }) => {
          expect(body.count).toBe(0);
        });
    });
  });

  describe('Session listing and admin revoke', () => {
    it('lists the current user sessions', async () => {
      await request(app.getHttpServer())
        .get('/sessions/me')
        .set('Authorization', auth(userToken))
        .expect(200)
        .expect(({ body }) => {
          expect(Array.isArray(body)).toBe(true);
          expect(body.length).toBeGreaterThanOrEqual(1);
        });
    });

    it('forbids a non-admin from revoking sessions', async () => {
      await request(app.getHttpServer())
        .delete(`/sessions/user/${userId}`)
        .set('Authorization', auth(userToken))
        .expect(403);
    });

    it('lets an admin revoke all sessions for a user', async () => {
      await request(app.getHttpServer())
        .delete(`/sessions/user/${userId}`)
        .set('Authorization', auth(adminToken))
        .expect(200);

      await request(app.getHttpServer())
        .get(`/sessions/user/${userId}`)
        .set('Authorization', auth(adminToken))
        .expect(200)
        .expect(({ body }) => {
          expect(Array.isArray(body)).toBe(true);
          expect(body).toHaveLength(0);
        });
    });
  });
});
