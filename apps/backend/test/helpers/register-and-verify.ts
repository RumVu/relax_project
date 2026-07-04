import { INestApplication } from '@nestjs/common';
import request from 'supertest';
import { App } from 'supertest/types';

export async function registerAndVerify(
  app: INestApplication<App>,
  data: { email: string; password: string; name: string },
) {
  const registered = await request(app.getHttpServer())
    .post('/auth/register')
    .send(data)
    .expect(201);

  const otp = registered.body.delivery?.devToken as string;
  if (!otp) {
    throw new Error(
      'No devToken in register response — is NODE_ENV=test and email provider unconfigured?',
    );
  }

  const verified = await request(app.getHttpServer())
    .post('/auth/otp/verify')
    .send({ email: data.email, code: otp })
    .expect(201);

  return verified;
}
