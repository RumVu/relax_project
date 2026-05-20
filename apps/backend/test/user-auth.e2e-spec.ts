import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import * as bcrypt from 'bcrypt';
import { UserRole } from '@prisma/client';
import { AppModule } from './../src/app.module';
import { ErrorCode } from './../src/common/errors/error-code';
import { HttpExceptionFilter } from './../src/common/errors/http-exception.filter';
import { PrismaService } from './../src/prisma/prisma.service';

describe('User and Auth APIs (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  const tag = `e2e-user-${Date.now()}`;
  const email = `${tag}@example.com`;
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

  it('registers, authenticates, updates related user records, and revokes sessions', async () => {
    const registered = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email, password, name: 'E2E User' })
      .expect(201)
      .expect(({ body }) => {
        expect(body.accessToken).toBeTruthy();
        expect(body.refreshToken).toBeTruthy();
        expect(body.user.email).toBe(email);
        expect(body.user.password).toBeUndefined();
        expect(body.user.profile.displayName).toBe('E2E User');
        expect(body.user.preferences.language).toBe('vi');
      });
    const { accessToken, refreshToken, user } = registered.body;
    const storedSession = await prisma.session.findFirstOrThrow({
      where: { userId: user.id },
    });
    expect(storedSession.refreshToken).not.toBe(refreshToken);
    expect(storedSession.refreshToken).toMatch(/^[a-f0-9]{64}$/);

    await request(app.getHttpServer())
      .get('/auth/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => expect(body.id).toBe(user.id));

    await prisma.user.update({
      where: { id: user.id },
      data: { isActive: false },
    });
    await request(app.getHttpServer())
      .get('/auth/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(401)
      .expect(({ body }) =>
        expect(body.code).toBe(ErrorCode.AUTH_INACTIVE_USER),
      );
    await prisma.user.update({
      where: { id: user.id },
      data: { isActive: true },
    });

    const admin = await prisma.user.create({
      data: {
        email: adminEmail,
        password: await bcrypt.hash(password, 12),
        role: UserRole.ADMIN,
        profile: { create: { displayName: 'E2E Admin' } },
        preferences: { create: {} },
      },
    });
    const adminLogin = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: admin.email, password })
      .expect(201);

    await request(app.getHttpServer())
      .get(`/users/${user.id}`)
      .set('Authorization', `Bearer ${adminLogin.body.accessToken}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body.email).toBe(email);
        expect(body.password).toBeUndefined();
      });

    await request(app.getHttpServer())
      .patch(`/user-profiles/${user.id}`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ bio: 'Should not pass' })
      .expect(403)
      .expect(({ body }) => {
        expect(body.code).toBe(ErrorCode.AUTH_FORBIDDEN);
      });

    await request(app.getHttpServer())
      .patch(`/user-profiles/${user.id}`)
      .set('Authorization', `Bearer ${adminLogin.body.accessToken}`)
      .send({ bio: 'Built by e2e' })
      .expect(200)
      .expect(({ body }) => expect(body.bio).toBe('Built by e2e'));

    await request(app.getHttpServer())
      .patch('/user-preferences/me/preferences')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ language: 'en', enableSound: false })
      .expect(200)
      .expect(({ body }) => {
        expect(body.language).toBe('en');
        expect(body.enableSound).toBe(false);
      });

    await request(app.getHttpServer())
      .get('/sessions/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => expect(body.length).toBeGreaterThan(0));

    const refreshed = await request(app.getHttpServer())
      .post('/auth/refresh')
      .send({ refreshToken })
      .expect(201)
      .expect(({ body }) => {
        expect(body.accessToken).toBeTruthy();
        expect(body.refreshToken).toBeTruthy();
        expect(body.refreshToken).not.toBe(refreshToken);
      });

    await request(app.getHttpServer())
      .post('/auth/logout')
      .send({ refreshToken: refreshed.body.refreshToken })
      .expect(201)
      .expect(({ body }) => expect(body.success).toBe(true));

    await request(app.getHttpServer())
      .delete(`/sessions/user/${user.id}`)
      .set('Authorization', `Bearer ${adminLogin.body.accessToken}`)
      .expect(200)
      .expect(({ body }) => expect(body.revoked).toBeGreaterThanOrEqual(0));
  });

  it('rejects duplicate registration and invalid login', async () => {
    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: `${tag}-duplicate@example.com`, password, name: 'One' })
      .expect(201);

    await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: `${tag}-duplicate@example.com`, password, name: 'Two' })
      .expect(409)
      .expect(({ body }) => {
        expect(body.code).toBe(ErrorCode.USER_EMAIL_ALREADY_EXISTS);
      });

    await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: `${tag}-duplicate@example.com`, password: 'Wrong123!x' })
      .expect(401)
      .expect(({ body }) => {
        expect(body.code).toBe(ErrorCode.AUTH_INVALID_CREDENTIALS);
      });
  });
});
