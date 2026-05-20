import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request, { Test as SupertestRequest } from 'supertest';
import { App } from 'supertest/types';
import { CompanionType, MoodType, ThemeMode, UserRole } from '@prisma/client';
import { AppModule } from './../src/app.module';
import { ErrorCode } from './../src/common/errors/error-code';
import { HttpExceptionFilter } from './../src/common/errors/http-exception.filter';
import { PrismaService } from './../src/prisma/prisma.service';

describe('Catalog APIs (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  const tag = `e2e-${Date.now()}`;
  const adminEmail = `${tag}-admin@example.com`;
  const userEmail = `${tag}-user@example.com`;
  const adminPassword = 'Password123!';
  let adminToken: string;
  let adminUserId: string;
  let userToken: string;
  const asAdmin = (testRequest: SupertestRequest) =>
    testRequest.set('Authorization', `Bearer ${adminToken}`);

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
    prisma = app.get(PrismaService);
    app.useGlobalFilters(new HttpExceptionFilter());
    await app.init();

    const registered = await request(app.getHttpServer())
      .post('/auth/register')
      .send({
        email: adminEmail,
        password: adminPassword,
        name: `${tag}-admin`,
      })
      .expect(201);
    adminUserId = registered.body.user.id;
    await prisma.user.update({
      where: { id: registered.body.user.id },
      data: { role: UserRole.ADMIN },
    });
    const loggedIn = await request(app.getHttpServer())
      .post('/auth/login')
      .send({ email: adminEmail, password: adminPassword })
      .expect(201);
    adminToken = loggedIn.body.accessToken;

    const registeredUser = await request(app.getHttpServer())
      .post('/auth/register')
      .send({
        email: userEmail,
        password: adminPassword,
        name: `${tag}-user`,
      })
      .expect(201);
    userToken = registeredUser.body.accessToken;
  });

  afterAll(async () => {
    await prisma.appTheme.deleteMany({ where: { name: { startsWith: tag } } });
    await prisma.onboardingSlide.deleteMany({
      where: { title: { startsWith: tag } },
    });
    await prisma.companionAsset.deleteMany({
      where: { name: { startsWith: tag } },
    });
    await prisma.companionMessage.deleteMany({
      where: { content: { startsWith: tag } },
    });
    await prisma.ambientSound.deleteMany({
      where: { title: { startsWith: tag } },
    });
    await prisma.breathingExercise.deleteMany({
      where: { title: { startsWith: tag } },
    });
    await prisma.cozyQuote.deleteMany({
      where: { content: { startsWith: tag } },
    });
    await prisma.storageFile.deleteMany({
      where: { filename: { startsWith: tag } },
    });
    await prisma.user.deleteMany({
      where: { email: { startsWith: tag } },
    });
    await app.close();
  });

  it('serves seeded read endpoints', async () => {
    await request(app.getHttpServer()).get('/app-themes').expect(200);
    await request(app.getHttpServer()).get('/app-themes/default').expect(200);
    await request(app.getHttpServer()).get('/onboarding-slides').expect(200);
    await request(app.getHttpServer()).get('/companion-assets').expect(200);
    await request(app.getHttpServer())
      .get('/companion-assets/default')
      .expect(200);
    await request(app.getHttpServer()).get('/companion-messages').expect(200);
    await request(app.getHttpServer())
      .get('/companion-messages/random')
      .expect(200);
    await request(app.getHttpServer()).get('/ambient-sounds').expect(200);
    await request(app.getHttpServer())
      .get('/ambient-sounds/category/RAIN')
      .expect(200);
    await request(app.getHttpServer()).get('/breathing-exercises').expect(200);
    await request(app.getHttpServer()).get('/cozy-quotes').expect(200);
    await request(app.getHttpServer()).get('/cozy-quotes/random').expect(200);
    await request(app.getHttpServer())
      .get('/cozy-quotes/mood/CALM')
      .expect(200);
  });

  it('creates, updates, and deletes app themes', async () => {
    const created = await asAdmin(
      request(app.getHttpServer()).post('/app-themes'),
    )
      .send({
        name: `${tag}-theme`,
        mode: ThemeMode.LIGHT,
        backgroundColor: '#ffffff',
        surfaceColor: '#f8fafc',
        primaryColor: '#2563eb',
        textColor: '#111827',
      })
      .expect(201);

    await asAdmin(
      request(app.getHttpServer()).patch(`/app-themes/${created.body.id}`),
    )
      .send({ accentColor: '#22c55e' })
      .expect(200)
      .expect(({ body }) => expect(body.accentColor).toBe('#22c55e'));

    await asAdmin(
      request(app.getHttpServer()).delete(`/app-themes/${created.body.id}`),
    ).expect(200);
  });

  it('creates, updates, and deletes onboarding slides', async () => {
    const created = await asAdmin(
      request(app.getHttpServer()).post('/onboarding-slides'),
    )
      .send({ title: `${tag}-slide`, displayOrder: 99 })
      .expect(201);

    await asAdmin(
      request(app.getHttpServer()).patch(
        `/onboarding-slides/${created.body.id}`,
      ),
    )
      .send({ subtitle: 'Updated subtitle' })
      .expect(200)
      .expect(({ body }) => expect(body.subtitle).toBe('Updated subtitle'));

    await asAdmin(
      request(app.getHttpServer()).delete(
        `/onboarding-slides/${created.body.id}`,
      ),
    ).expect(200);
  });

  it('creates, updates, and deletes companion assets', async () => {
    const created = await asAdmin(
      request(app.getHttpServer()).post('/companion-assets'),
    )
      .send({ name: `${tag}-asset`, type: CompanionType.CAT })
      .expect(201);

    await asAdmin(
      request(app.getHttpServer()).patch(
        `/companion-assets/${created.body.id}`,
      ),
    )
      .send({ accentColor: '#f97316' })
      .expect(200)
      .expect(({ body }) => expect(body.accentColor).toBe('#f97316'));

    await asAdmin(
      request(app.getHttpServer()).delete(
        `/companion-assets/${created.body.id}`,
      ),
    ).expect(200);
  });

  it('keeps app theme and companion asset defaults active and recoverable', async () => {
    const defaultTheme = await asAdmin(
      request(app.getHttpServer()).post('/app-themes'),
    )
      .send({
        name: `${tag}-default-theme`,
        mode: ThemeMode.DARK,
        backgroundColor: '#020617',
        surfaceColor: '#111827',
        primaryColor: '#38bdf8',
        textColor: '#f8fafc',
        isDefault: true,
        isActive: false,
      })
      .expect(201)
      .expect(({ body }) => {
        expect(body.isDefault).toBe(true);
        expect(body.isActive).toBe(true);
      });

    await asAdmin(
      request(app.getHttpServer()).delete(
        `/app-themes/${defaultTheme.body.id}`,
      ),
    ).expect(200);
    await request(app.getHttpServer()).get('/app-themes/default').expect(200);

    const defaultAsset = await asAdmin(
      request(app.getHttpServer()).post('/companion-assets'),
    )
      .send({
        name: `${tag}-default-asset`,
        type: CompanionType.CAT,
        isDefault: true,
        isActive: false,
      })
      .expect(201)
      .expect(({ body }) => {
        expect(body.isDefault).toBe(true);
        expect(body.isActive).toBe(true);
      });

    await asAdmin(
      request(app.getHttpServer()).delete(
        `/companion-assets/${defaultAsset.body.id}`,
      ),
    ).expect(200);
    await request(app.getHttpServer())
      .get('/companion-assets/default')
      .expect(200);
  });

  it('creates, updates, and deletes companion messages', async () => {
    const created = await asAdmin(
      request(app.getHttpServer()).post('/companion-messages'),
    )
      .send({ content: `${tag}-message`, weight: 2 })
      .expect(201);

    await asAdmin(
      request(app.getHttpServer()).patch(
        `/companion-messages/${created.body.id}`,
      ),
    )
      .send({ isActive: false })
      .expect(200)
      .expect(({ body }) => expect(body.isActive).toBe(false));

    await asAdmin(
      request(app.getHttpServer()).delete(
        `/companion-messages/${created.body.id}`,
      ),
    ).expect(200);
  });

  it('creates, updates, and deletes ambient sounds', async () => {
    const created = await asAdmin(
      request(app.getHttpServer()).post('/ambient-sounds'),
    )
      .send({
        title: `${tag}-sound`,
        category: 'TEST',
        soundUrl: 'https://example.com/test.mp3',
      })
      .expect(201);

    await asAdmin(
      request(app.getHttpServer()).patch(`/ambient-sounds/${created.body.id}`),
    )
      .send({ duration: 60 })
      .expect(200)
      .expect(({ body }) => expect(body.duration).toBe(60));

    await asAdmin(
      request(app.getHttpServer()).delete(`/ambient-sounds/${created.body.id}`),
    ).expect(200);
  });

  it('creates, updates, and deletes breathing exercises', async () => {
    const created = await asAdmin(
      request(app.getHttpServer()).post('/breathing-exercises'),
    )
      .send({
        title: `${tag}-breathing`,
        inhaleSeconds: 4,
        holdSeconds: 2,
        exhaleSeconds: 6,
        cycles: 3,
      })
      .expect(201);

    await asAdmin(
      request(app.getHttpServer()).patch(
        `/breathing-exercises/${created.body.id}`,
      ),
    )
      .send({ duration: 36 })
      .expect(200)
      .expect(({ body }) => expect(body.duration).toBe(36));

    await asAdmin(
      request(app.getHttpServer()).delete(
        `/breathing-exercises/${created.body.id}`,
      ),
    ).expect(200);
  });

  it('creates, updates, and deletes cozy quotes', async () => {
    const created = await asAdmin(
      request(app.getHttpServer()).post('/cozy-quotes'),
    )
      .send({ content: `${tag}-quote`, mood: MoodType.CALM })
      .expect(201);

    await asAdmin(
      request(app.getHttpServer()).patch(`/cozy-quotes/${created.body.id}`),
    )
      .send({ author: 'E2E' })
      .expect(200)
      .expect(({ body }) => expect(body.author).toBe('E2E'));

    await asAdmin(
      request(app.getHttpServer()).delete(`/cozy-quotes/${created.body.id}`),
    ).expect(200);
  });

  it('returns stable error codes for validation, not found, and database errors', async () => {
    await request(app.getHttpServer())
      .post('/app-themes')
      .send({ name: `${tag}-unauthorized-theme` })
      .expect(401)
      .expect(({ body }) => {
        expect(body.success).toBe(false);
        expect(body.code).toBe(ErrorCode.AUTH_UNAUTHORIZED);
        expect(body.statusCode).toBe(401);
      });

    await asAdmin(request(app.getHttpServer()).post('/app-themes'))
      .send({ name: `${tag}-invalid-theme` })
      .expect(400)
      .expect(({ body }) => {
        expect(body.success).toBe(false);
        expect(body.code).toBe(ErrorCode.VALIDATION_FAILED);
        expect(body.statusCode).toBe(400);
        expect(body.path).toBe('/app-themes');
      });

    await asAdmin(
      request(app.getHttpServer()).patch('/ambient-sounds/missing-id'),
    )
      .send({ title: 'Missing' })
      .expect(404)
      .expect(({ body }) => {
        expect(body.success).toBe(false);
        expect(body.code).toBe(ErrorCode.CATALOG_AMBIENT_SOUND_NOT_FOUND);
        expect(body.statusCode).toBe(404);
      });

    const duplicateName = `${tag}-duplicate-theme`;
    await asAdmin(request(app.getHttpServer()).post('/app-themes'))
      .send({
        name: duplicateName,
        mode: ThemeMode.LIGHT,
        backgroundColor: '#ffffff',
        surfaceColor: '#f8fafc',
        primaryColor: '#2563eb',
        textColor: '#111827',
      })
      .expect(201);

    await asAdmin(request(app.getHttpServer()).post('/app-themes'))
      .send({
        name: duplicateName,
        mode: ThemeMode.DARK,
        backgroundColor: '#000000',
        surfaceColor: '#111827',
        primaryColor: '#60a5fa',
        textColor: '#ffffff',
      })
      .expect(409)
      .expect(({ body }) => {
        expect(body.success).toBe(false);
        expect(body.code).toBe(ErrorCode.DATABASE_UNIQUE_CONSTRAINT);
        expect(body.statusCode).toBe(409);
      });
  });

  it('returns storage health, public URLs, and registers file metadata', async () => {
    const storageHealth = await asAdmin(
      request(app.getHttpServer()).get('/storage/health'),
    ).expect(200);

    const publicUrlRequest = asAdmin(
      request(app.getHttpServer()).get('/storage/admin/public-url'),
    ).query({ path: `${tag}/image.png` });

    if (storageHealth.body.configured) {
      await publicUrlRequest.expect(200).expect(({ body }) => {
        expect(body.path).toBe(`${tag}/image.png`);
        expect(body.publicUrl).toContain(`${tag}/image.png`);
      });
    } else {
      await publicUrlRequest.expect(503).expect(({ body }) => {
        expect(body.code).toBe(ErrorCode.STORAGE_NOT_CONFIGURED);
      });
    }

    const created = await request(app.getHttpServer())
      .post('/storage/files')
      .set('Authorization', `Bearer ${adminToken}`)
      .send({
        filename: `${tag}-image.png`,
        mimetype: 'image/png',
        size: 128,
        path: `${tag}/image.png`,
        isPublic: false,
      })
      .expect(201);

    expect(created.body.userId).toBeDefined();
    expect(created.body.path).toBe(
      `user-uploads/${created.body.userId}/${tag}/image.png`,
    );

    await request(app.getHttpServer())
      .get('/storage/files')
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);

    await request(app.getHttpServer())
      .get('/storage/me/files')
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);

    await request(app.getHttpServer())
      .delete(`/storage/files/${created.body.id}`)
      .set('Authorization', `Bearer ${adminToken}`)
      .expect(200);
  });

  it('scopes user storage read URLs to the authenticated user', async () => {
    await request(app.getHttpServer())
      .get('/storage/public-url')
      .set('Authorization', `Bearer ${userToken}`)
      .query({ path: `user-uploads/${adminUserId}/${tag}/image.png` })
      .expect(403)
      .expect(({ body }) => {
        expect(body.code).toBe(ErrorCode.STORAGE_INVALID_PATH);
      });

    await request(app.getHttpServer())
      .get('/storage/signed-url')
      .set('Authorization', `Bearer ${userToken}`)
      .query({ path: `user-uploads/${adminUserId}/${tag}/image.png` })
      .expect(403)
      .expect(({ body }) => {
        expect(body.code).toBe(ErrorCode.STORAGE_INVALID_PATH);
      });
  });
});
