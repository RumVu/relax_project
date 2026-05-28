import type { Request } from 'express';
import { getClientIp } from './client-ip';

function makeReq(opts: {
  headers?: Record<string, string | string[]>;
  ip?: string;
  remoteAddress?: string;
}): Request {
  return {
    headers: opts.headers ?? {},
    ip: opts.ip,
    socket: { remoteAddress: opts.remoteAddress } as Request['socket'],
  } as unknown as Request;
}

describe('getClientIp', () => {
  it('prefers cf-connecting-ip over everything else', () => {
    const req = makeReq({
      headers: {
        'cf-connecting-ip': '203.0.113.7',
        'x-forwarded-for': '198.51.100.1, 10.0.0.1',
        'x-real-ip': '198.51.100.99',
      },
      ip: '::1',
      remoteAddress: '127.0.0.1',
    });
    expect(getClientIp(req)).toBe('203.0.113.7');
  });

  it('falls back to true-client-ip when cf-connecting-ip is absent', () => {
    const req = makeReq({
      headers: { 'true-client-ip': '203.0.113.8' },
      ip: '::1',
    });
    expect(getClientIp(req)).toBe('203.0.113.8');
  });

  it('falls back to x-real-ip when CF headers are absent', () => {
    const req = makeReq({
      headers: { 'x-real-ip': '198.51.100.42' },
      ip: '::1',
    });
    expect(getClientIp(req)).toBe('198.51.100.42');
  });

  it('uses the left-most entry of x-forwarded-for', () => {
    const req = makeReq({
      headers: { 'x-forwarded-for': '203.0.113.10, 10.0.0.1, 10.0.0.2' },
      ip: '::1',
    });
    expect(getClientIp(req)).toBe('203.0.113.10');
  });

  it('handles x-forwarded-for as an array header', () => {
    const req = makeReq({
      headers: { 'x-forwarded-for': ['203.0.113.11, 10.0.0.1'] },
    });
    expect(getClientIp(req)).toBe('203.0.113.11');
  });

  it('falls back to req.ip when no proxy headers are present', () => {
    const req = makeReq({ ip: '198.51.100.5' });
    expect(getClientIp(req)).toBe('198.51.100.5');
  });

  it('falls back to socket.remoteAddress as a last resort', () => {
    const req = makeReq({ remoteAddress: '198.51.100.6' });
    expect(getClientIp(req)).toBe('198.51.100.6');
  });

  it('strips IPv4-mapped IPv6 prefix (::ffff:)', () => {
    const req = makeReq({ headers: { 'cf-connecting-ip': '::ffff:1.2.3.4' } });
    expect(getClientIp(req)).toBe('1.2.3.4');

    const req2 = makeReq({ ip: '::ffff:5.6.7.8' });
    expect(getClientIp(req2)).toBe('5.6.7.8');
  });

  it('preserves real IPv6 addresses', () => {
    const req = makeReq({
      headers: { 'cf-connecting-ip': '2001:db8::1' },
    });
    expect(getClientIp(req)).toBe('2001:db8::1');
  });

  it('ignores empty header values', () => {
    const req = makeReq({
      headers: {
        'cf-connecting-ip': '',
        'x-forwarded-for': '   , 10.0.0.1',
      },
      ip: '203.0.113.20',
    });
    expect(getClientIp(req)).toBe('203.0.113.20');
  });

  it('returns undefined when nothing is available', () => {
    const req = makeReq({});
    expect(getClientIp(req)).toBeUndefined();
  });

  it('trims whitespace from header values', () => {
    const req = makeReq({
      headers: { 'cf-connecting-ip': '  203.0.113.30  ' },
    });
    expect(getClientIp(req)).toBe('203.0.113.30');
  });
});
