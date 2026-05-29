import { isAllowedOrigin } from './cors';

describe('isAllowedOrigin', () => {
  const PROD = true;
  const DEV = false;

  describe('explicit allow-list', () => {
    it('allows exact matches in both prod and dev', () => {
      const origins = ['https://app.example.com'];
      expect(isAllowedOrigin('https://app.example.com', origins, PROD)).toBe(
        true,
      );
      expect(isAllowedOrigin('https://app.example.com', origins, DEV)).toBe(
        true,
      );
    });

    it('rejects unknown origins in production', () => {
      expect(isAllowedOrigin('https://evil.example.com', [], PROD)).toBe(false);
    });
  });

  describe('localhost (dev only)', () => {
    it('allows http://localhost on any port in dev', () => {
      expect(isAllowedOrigin('http://localhost', [], DEV)).toBe(true);
      expect(isAllowedOrigin('http://localhost:3000', [], DEV)).toBe(true);
      expect(isAllowedOrigin('https://localhost:6823', [], DEV)).toBe(true);
    });

    it('allows http://127.0.0.1 on any port in dev', () => {
      expect(isAllowedOrigin('http://127.0.0.1:3233', [], DEV)).toBe(true);
    });

    it('blocks localhost in production', () => {
      expect(isAllowedOrigin('http://localhost:3000', [], PROD)).toBe(false);
    });
  });

  describe('*.trycloudflare.com (dev only)', () => {
    it('allows https://*.trycloudflare.com in dev', () => {
      expect(
        isAllowedOrigin(
          'https://constructed-alaska-mistakes-pal.trycloudflare.com',
          [],
          DEV,
        ),
      ).toBe(true);
      expect(
        isAllowedOrigin('https://abc-def.trycloudflare.com', [], DEV),
      ).toBe(true);
    });

    it('blocks trycloudflare in production', () => {
      expect(
        isAllowedOrigin('https://abc-def.trycloudflare.com', [], PROD),
      ).toBe(false);
    });

    it('does not match unrelated cloudflare or look-alike hosts', () => {
      expect(isAllowedOrigin('https://trycloudflare.com', [], DEV)).toBe(false);
      expect(
        isAllowedOrigin('https://evil.trycloudflare.com.attacker.com', [], DEV),
      ).toBe(false);
      expect(isAllowedOrigin('http://abc.trycloudflare.com', [], DEV)).toBe(
        false,
      ); // http:// not allowed
    });
  });

  describe('private LAN ranges (dev only)', () => {
    it('allows 192.168.x.x on any port', () => {
      expect(isAllowedOrigin('http://192.168.1.12:3233', [], DEV)).toBe(true);
      expect(isAllowedOrigin('http://192.168.0.5', [], DEV)).toBe(true);
      expect(isAllowedOrigin('https://192.168.50.100:8080', [], DEV)).toBe(
        true,
      );
    });

    it('allows 10.x.x.x', () => {
      expect(isAllowedOrigin('http://10.0.0.5:3233', [], DEV)).toBe(true);
      expect(isAllowedOrigin('http://10.50.100.200', [], DEV)).toBe(true);
    });

    it('allows 172.16-31.x.x (RFC 1918) but not 172.32+', () => {
      expect(isAllowedOrigin('http://172.16.0.1:3233', [], DEV)).toBe(true);
      expect(isAllowedOrigin('http://172.20.50.100', [], DEV)).toBe(true);
      expect(isAllowedOrigin('http://172.31.255.255', [], DEV)).toBe(true);
      expect(isAllowedOrigin('http://172.15.0.1', [], DEV)).toBe(false);
      expect(isAllowedOrigin('http://172.32.0.1', [], DEV)).toBe(false);
    });

    it('does not match public IPs', () => {
      expect(isAllowedOrigin('http://8.8.8.8', [], DEV)).toBe(false);
      expect(isAllowedOrigin('http://203.0.113.5:3233', [], DEV)).toBe(false);
    });

    it('blocks private LAN in production', () => {
      expect(isAllowedOrigin('http://192.168.1.12:3233', [], PROD)).toBe(false);
      expect(isAllowedOrigin('http://10.0.0.5', [], PROD)).toBe(false);
    });
  });

  describe('wildcard *', () => {
    it('allows any origin when * is in the list and not in production', () => {
      expect(isAllowedOrigin('https://anything.example.com', ['*'], DEV)).toBe(
        true,
      );
    });

    it('ignores * in production', () => {
      expect(isAllowedOrigin('https://anything.example.com', ['*'], PROD)).toBe(
        false,
      );
    });
  });
});
