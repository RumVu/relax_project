import { INestApplication, ValidationPipe } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import { ReminderType, UserRole } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { ErrorCode } from './../src/common/errors/error-code';
import { HttpExceptionFilter } from './../src/common/errors/http-exception.filter';
import { PrismaService } from './../src/prisma/prisma.service';

describe('Reminders APIs (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  const tag = `e2e-reminders-${Date.now()}`;
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

  it('creates, lists, updates, protects, and deletes reminders', async () => {
    const registered = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email, password, name: 'Reminder User' })
      .expect(201);
    const accessToken = registered.body.accessToken as string;
    const userId = registered.body.user.id as string;

    await request(app.getHttpServer())
      .get('/reminders/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body.total).toBe(0);
        expect(body.items).toEqual([]);
      });

    const created = await request(app.getHttpServer())
      .post('/reminders/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({
        title: 'Uống nước một chút nha',
        message: 'Một ngụm nước nhỏ cũng tính.',
        type: ReminderType.WATER,
        scheduledAt: new Date(Date.now() + 1000 * 60 * 60).toISOString(),
        repeatRule: '0 9 * * *',
      })
      .expect(201)
      .expect(({ body }) => {
        expect(body.title).toBe('Uống nước một chút nha');
        expect(body.type).toBe(ReminderType.WATER);
        expect(body.isActive).toBe(true);
      });

    await request(app.getHttpServer())
      .get('/reminders/me/stats')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body.total).toBe(1);
        expect(body.active).toBe(1);
        expect(body.upcoming).toBe(1);
      });

    await request(app.getHttpServer())
      .get('/reminders/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .query({ type: ReminderType.WATER, limit: 10 })
      .expect(200)
      .expect(({ body }) => {
        expect(body.total).toBe(1);
        expect(body.items[0].id).toBe(created.body.id);
      });

    await request(app.getHttpServer())
      .patch(`/reminders/${created.body.id}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ title: 'Đứng dậy duỗi vai', isActive: false })
      .expect(200)
      .expect(({ body }) => {
        expect(body.title).toBe('Đứng dậy duỗi vai');
        expect(body.isActive).toBe(false);
      });

    await request(app.getHttpServer())
      .get(`/reminders/${created.body.id}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => expect(body.id).toBe(created.body.id));

    const otherRegistered = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: otherEmail, password, name: 'Other User' })
      .expect(201);

    await request(app.getHttpServer())
      .get(`/reminders/${created.body.id}`)
      .set('Authorization', `Bearer ${otherRegistered.body.accessToken}`)
      .expect(403)
      .expect(({ body }) => expect(body.code).toBe(ErrorCode.AUTH_FORBIDDEN));

    const admin = await prisma.user.create({
      data: {
        email: adminEmail,
        password: await bcrypt.hash(password, 12),
        role: UserRole.ADMIN,
        profile: { create: { displayName: 'Reminder Admin' } },
        preferences: { create: {} },
      },
    });
    const adminLogin = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: admin.email, password })
      .expect(201);

    await request(app.getHttpServer())
      .get('/reminders')
      .set('Authorization', `Bearer ${adminLogin.body.accessToken}`)
      .expect(200)
      .expect(({ body }) => expect(body.total).toBeGreaterThanOrEqual(1));

    await request(app.getHttpServer())
      .get(`/reminders/user/${userId}`)
      .set('Authorization', `Bearer ${adminLogin.body.accessToken}`)
      .expect(200)
      .expect(({ body }) => expect(body.total).toBe(1));

    await request(app.getHttpServer())
      .delete(`/reminders/${created.body.id}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => expect(body.success).toBe(true));

    await request(app.getHttpServer())
      .get(`/reminders/${created.body.id}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(404)
      .expect(({ body }) =>
        expect(body.code).toBe(ErrorCode.REMINDER_NOT_FOUND),
      );
  });
});
