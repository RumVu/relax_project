import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { MoodType, UserRole } from '@prisma/client';
import { AppModule } from './../src/app.module';
import { HttpExceptionFilter } from './../src/common/errors/http-exception.filter';
import { PrismaService } from './../src/prisma/prisma.service';

describe('Admin modules and list search/filter (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  const tag = `e2e-adminsearch-${Date.now()}`;
  const adminEmail = `${tag}-admin@example.com`;
  const userEmail = `${tag}-user@example.com`;
  const password = 'Password123!';
  const quoteContent = `${tag} keep calm and breathe slowly`;
  let adminToken: string;
  let userToken: string;

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
    const loggedInAdmin = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: adminEmail, password })
      .expect(201);
    adminToken = loggedInAdmin.body.accessToken;

    const registeredUser = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: userEmail, password, name: `${tag}-user` })
      .expect(201);
    userToken = registeredUser.body.accessToken;

    await request(app.getHttpServer())
      .post('/cozy-quotes')
      .set('Authorization', auth(adminToken))
      .send({ content: quoteContent, mood: MoodType.CALM })
      .expect(201);
  });

  afterAll(async () => {
    await prisma.cozyQuote.deleteMany({
      where: { content: { startsWith: tag } },
    });
    await prisma.user.deleteMany({
      where: { email: { startsWith: tag } },
    });
    await app.close();
  });

  describe('Catalog list search and pagination', () => {
    it('returns the paginated page shape', async () => {
      await request(app.getHttpServer())
        .get('/cozy-quotes')
        .expect(200)
        .expect(({ body }) => {
          expect(Array.isArray(body.items)).toBe(true);
          expect(typeof body.total).toBe('number');
          expect(typeof body.hasMore).toBe('boolean');
        });
    });

    it('filters catalog items by free-text q', async () => {
      await request(app.getHttpServer())
        .get('/cozy-quotes')
        .query({ q: tag })
        .expect(200)
        .expect(({ body }) => {
          expect(body.total).toBeGreaterThanOrEqual(1);
          expect(
            body.items.some((item: { content?: string }) =>
              item.content?.includes(tag),
            ),
          ).toBe(true);
        });
    });

    it('returns an empty page when q matches nothing', async () => {
      await request(app.getHttpServer())
        .get('/cozy-quotes')
        .query({ q: `${tag}-no-such-quote` })
        .expect(200)
        .expect(({ body }) => {
          expect(body.total).toBe(0);
          expect(body.items).toHaveLength(0);
        });
    });

    it('respects the limit param', async () => {
      await request(app.getHttpServer())
        .get('/cozy-quotes')
        .query({ limit: 1 })
        .expect(200)
        .expect(({ body }) => {
          expect(body.items.length).toBeLessThanOrEqual(1);
          expect(body.limit).toBe(1);
        });
    });
  });

  describe('Users list filters (admin only)', () => {
    it('requires authentication', async () => {
      await request(app.getHttpServer()).get('/users').expect(401);
    });

    it('forbids non-admin users', async () => {
      await request(app.getHttpServer())
        .get('/users')
        .set('Authorization', auth(userToken))
        .expect(403);
    });

    it('searches users by email/name', async () => {
      await request(app.getHttpServer())
        .get('/users')
        .query({ search: tag })
        .set('Authorization', auth(adminToken))
        .expect(200)
        .expect(({ body }) => {
          expect(body.total).toBeGreaterThanOrEqual(2);
          expect(
            body.items.every((item: { email: string }) =>
              item.email.startsWith(tag),
            ),
          ).toBe(true);
        });
    });

    it('filters users by role', async () => {
      await request(app.getHttpServer())
        .get('/users')
        .query({ role: UserRole.ADMIN })
        .set('Authorization', auth(adminToken))
        .expect(200)
        .expect(({ body }) => {
          expect(
            body.items.every(
              (item: { role: string }) => item.role === UserRole.ADMIN,
            ),
          ).toBe(true);
        });
    });

    it('filters users by active status', async () => {
      await request(app.getHttpServer())
        .get('/users')
        .query({ status: 'ACTIVE' })
        .set('Authorization', auth(adminToken))
        .expect(200)
        .expect(({ body }) => {
          expect(
            body.items.every(
              (item: { isActive: boolean }) => item.isActive === true,
            ),
          ).toBe(true);
        });
    });
  });

  describe('Admin dashboard', () => {
    it('serves the aggregate overview to admins', async () => {
      await request(app.getHttpServer())
        .get('/admin/analytics/overview')
        .set('Authorization', auth(adminToken))
        .expect(200)
        .expect(({ body }) => {
          expect(body).toBeDefined();
          expect(typeof body).toBe('object');
        });
    });

    it('rejects overview for non-admins and anonymous', async () => {
      await request(app.getHttpServer())
        .get('/admin/analytics/overview')
        .expect(401);
      await request(app.getHttpServer())
        .get('/admin/analytics/overview')
        .set('Authorization', auth(userToken))
        .expect(403);
    });

    it('serves global search to admins', async () => {
      await request(app.getHttpServer())
        .get('/admin/search')
        .query({ q: tag })
        .set('Authorization', auth(adminToken))
        .expect(200);
    });
  });

  describe('Admin logs', () => {
    it('lists audit logs for admins', async () => {
      await request(app.getHttpServer())
        .get('/admin-logs')
        .set('Authorization', auth(adminToken))
        .expect(200)
        .expect(({ body }) => {
          expect(Array.isArray(body.items)).toBe(true);
          expect(typeof body.total).toBe('number');
        });
    });

    it('rejects audit logs for non-admins and anonymous', async () => {
      await request(app.getHttpServer()).get('/admin-logs').expect(401);
      await request(app.getHttpServer())
        .get('/admin-logs')
        .set('Authorization', auth(userToken))
        .expect(403);
    });
  });
});
