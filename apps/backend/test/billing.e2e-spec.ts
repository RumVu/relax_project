import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { ErrorCode } from './../src/common/errors/error-code';
import { HttpExceptionFilter } from './../src/common/errors/http-exception.filter';
import { PrismaService } from './../src/prisma/prisma.service';

describe('Billing checkout and activation (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  const tag = `e2e-billing-${Date.now()}`;
  const email = `${tag}@example.com`;
  const otherEmail = `${tag}-other@example.com`;
  const password = 'Secret123!x';
  let accessToken: string;
  let otherToken: string;

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
      .send({ email, password, name: 'Billing E2E' })
      .expect(201);
    accessToken = registered.body.accessToken;

    const otherRegistered = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email: otherEmail, password, name: 'Billing E2E Other' })
      .expect(201);
    otherToken = otherRegistered.body.accessToken;
  });

  afterAll(async () => {
    await prisma.user.deleteMany({
      where: { email: { endsWith: '@example.com', startsWith: tag } },
    });
    await app.close();
  });

  it('starts on the synthetic FREE plan before any purchase', async () => {
    await request(app.getHttpServer())
      .get('/billing/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body.subscription.planName).toBe('FREE');
        expect(body.subscription.status).toBe('ACTIVE');
      });
  });

  it('confirms a pending payment and activates the paid subscription', async () => {
    const checkout = await request(app.getHttpServer())
      .post('/billing/me/checkout-session')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ planName: 'CHILL_PLUS' })
      .expect(201);

    const paymentId: string = checkout.body.payment.id;
    const planName: string = checkout.body.plan.name;
    expect(checkout.body.payment.status).toBe('PENDING');
    expect(paymentId).toBeTruthy();

    await request(app.getHttpServer())
      .post(`/billing/me/payments/${paymentId}/confirm`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ planName })
      .expect(201)
      .expect(({ body }) => {
        const subscription = body.subscription as {
          endDate: string;
          planName: string;
          startDate: string;
          status: string;
        };
        expect(body.payment.status).toBe('COMPLETED');
        expect(subscription.status).toBe('ACTIVE');
        expect(subscription.planName).toBe(planName);
        expect(new Date(subscription.endDate).getTime()).toBeGreaterThan(
          new Date(subscription.startDate).getTime(),
        );
      });

    await request(app.getHttpServer())
      .get('/billing/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .expect(200)
      .expect(({ body }) => {
        expect(body.subscription.status).toBe('ACTIVE');
        expect(body.subscription.planName).toBe(planName);
      });
  });

  it('rejects confirming the same payment twice', async () => {
    const checkout = await request(app.getHttpServer())
      .post('/billing/me/checkout-session')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ planName: 'CHILL_PLUS' })
      .expect(201);
    const paymentId: string = checkout.body.payment.id;
    const planName: string = checkout.body.plan.name;

    await request(app.getHttpServer())
      .post(`/billing/me/payments/${paymentId}/confirm`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ planName })
      .expect(201);

    await request(app.getHttpServer())
      .post(`/billing/me/payments/${paymentId}/confirm`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ planName })
      .expect(409)
      .expect(({ body }) => {
        expect(body.code).toBe(ErrorCode.PAYMENT_NOT_PENDING);
      });
  });

  it('rejects confirming with a plan whose price does not match the payment', async () => {
    const checkout = await request(app.getHttpServer())
      .post('/billing/me/checkout-session')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ planName: 'CHILL_PLUS' })
      .expect(201);
    const paymentId: string = checkout.body.payment.id;

    await request(app.getHttpServer())
      .post(`/billing/me/payments/${paymentId}/confirm`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ planName: 'FREE' })
      .expect(400)
      .expect(({ body }) => {
        expect(body.code).toBe(ErrorCode.PAYMENT_PLAN_MISMATCH);
      });
  });

  it('does not let another user confirm a payment they do not own', async () => {
    const checkout = await request(app.getHttpServer())
      .post('/billing/me/checkout-session')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ planName: 'CHILL_PLUS' })
      .expect(201);
    const paymentId: string = checkout.body.payment.id;
    const planName: string = checkout.body.plan.name;

    await request(app.getHttpServer())
      .post(`/billing/me/payments/${paymentId}/confirm`)
      .set('Authorization', `Bearer ${otherToken}`)
      .send({ planName })
      .expect(404)
      .expect(({ body }) => {
        expect(body.code).toBe(ErrorCode.PAYMENT_NOT_FOUND);
      });
  });

  it('requires authentication to confirm a payment', async () => {
    await request(app.getHttpServer())
      .post('/billing/me/payments/some-id/confirm')
      .send({ planName: 'CHILL_PLUS' })
      .expect(401);
  });
});
