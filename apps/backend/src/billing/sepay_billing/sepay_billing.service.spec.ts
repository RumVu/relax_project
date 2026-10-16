import { ConfigService } from '@nestjs/config';
import { PrismaService } from '../../prisma/prisma.service';
import { BillingService } from '../billing.service';
import { SepayBillingService } from './sepay_billing.service';

function serviceWithKey(key?: string) {
  const config = { get: () => key } as unknown as ConfigService;
  return new SepayBillingService(
    {} as PrismaService,
    config,
    {} as BillingService,
  );
}

describe('SepayBillingService — verifyWebhookToken', () => {
  const service = serviceWithKey('secret-key');

  it('accepts the configured key with or without the Apikey prefix', () => {
    expect(service.verifyWebhookToken('Apikey secret-key')).toBe(true);
    expect(service.verifyWebhookToken('apikey   secret-key')).toBe(true);
    expect(service.verifyWebhookToken('secret-key')).toBe(true);
  });

  it('rejects missing, wrong or differently sized keys', () => {
    expect(service.verifyWebhookToken(undefined)).toBe(false);
    expect(service.verifyWebhookToken('Apikey wrong-key!')).toBe(false);
    expect(service.verifyWebhookToken('Apikey secret')).toBe(false);
  });

  it('rejects everything when no key is configured', () => {
    expect(serviceWithKey(undefined).verifyWebhookToken('Apikey ')).toBe(false);
  });

  it('handles pathological headers quickly', () => {
    const start = Date.now();
    service.verifyWebhookToken('apikey ' + ' '.repeat(100_000));
    expect(Date.now() - start).toBeLessThan(100);
  });
});
