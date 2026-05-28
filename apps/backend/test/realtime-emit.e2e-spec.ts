import { Test, TestingModule } from '@nestjs/testing';
import { INestApplication, ValidationPipe } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';
import { AppModule } from './../src/app.module';
import { HttpExceptionFilter } from './../src/common/errors/http-exception.filter';
import { PrismaService } from './../src/prisma/prisma.service';
import { RealtimeService } from './../src/realtime/realtime.service';

// The realtime gateway's actual websocket adapter is wired in main.ts only, so
// e2e tests do not attach a socket server. Instead this spec spies on the
// singleton RealtimeService and asserts that the user-facing write paths call
// emitToUser with the right event name and userId. This proves the wiring
// from feature services -> RealtimeService is intact end-to-end.

describe('Realtime emit wiring (e2e)', () => {
  let app: INestApplication<App>;
  let prisma: PrismaService;
  let realtime: RealtimeService;
  let emitSpy: jest.SpyInstance;
  const tag = `e2e-realtime-${Date.now()}`;
  const email = `${tag}@example.com`;
  const password = 'Password123!';
  let accessToken: string;
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
    realtime = app.get(RealtimeService);
    await app.init();

    const registered = await request(app.getHttpServer())
      .post('/auth/register')
      .send({ email, password, name: `${tag}-user` })
      .expect(201);
    accessToken = registered.body.accessToken;
    userId = registered.body.user.id;
  });

  beforeEach(() => {
    emitSpy = jest.spyOn(realtime, 'emitToUser');
  });

  afterEach(() => {
    emitSpy.mockRestore();
  });

  afterAll(async () => {
    await prisma.user.deleteMany({
      where: { email: { startsWith: tag } },
    });
    await app.close();
  });

  const expectEmit = (eventName: string) => {
    const matching = emitSpy.mock.calls.filter(
      ([emitUserId, name]) => emitUserId === userId && name === eventName,
    );
    expect(matching.length).toBeGreaterThan(0);
  };

  it('emits mood.updated after creating a mood check-in', async () => {
    await request(app.getHttpServer())
      .post('/mood-checkins/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ mood: 'CALM', intensity: 3 })
      .expect(201);

    expectEmit('mood.updated');
  });

  it('emits journal.created after creating a journal', async () => {
    await request(app.getHttpServer())
      .post('/journals/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ content: `${tag} journal body`, mood: 'CALM' })
      .expect(201);

    expectEmit('journal.created');
  });

  it('emits notification.created after sending a test notification', async () => {
    await request(app.getHttpServer())
      .post('/notifications/me/test')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ title: `${tag} hello`, message: 'realtime emit check' })
      .expect(201);

    expectEmit('notification.created');
  });

  it('emits companion.updated after upserting the user companion', async () => {
    await request(app.getHttpServer())
      .patch('/user-companions/me')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ name: `${tag} Pet` })
      .expect(200);

    expectEmit('companion.updated');
  });

  it('emits relax-session.updated after finishing a relax session', async () => {
    const started = await request(app.getHttpServer())
      .post('/relax-sessions/start')
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ activityType: 'BREATHING', title: `${tag} session` })
      .expect(201);

    const sessionId = started.body.id;

    // Clear spy so we only see emits from the finish call.
    emitSpy.mockClear();

    await request(app.getHttpServer())
      .post(`/relax-sessions/${sessionId}/finish`)
      .set('Authorization', `Bearer ${accessToken}`)
      .send({ reliefLevel: 4 })
      .expect(201);

    expectEmit('relax-session.updated');
  });
});
