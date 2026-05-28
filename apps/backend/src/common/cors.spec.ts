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
