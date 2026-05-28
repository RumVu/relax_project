import type { Request } from 'express';

/**
 * Extracts the *real* client IP from an incoming HTTP request.
 *
 * When the backend sits behind a proxy (Cloudflare tunnel/CDN, Nginx,
 * load balancer), `req.ip` ends up being the proxy's local address
 * (often `::1` or `127.0.0.1`). The original client address only
 * survives in upstream-injected headers. This helper tries them in
 * priority order, falling back to `req.ip` and finally the raw
 * socket address when no headers are present.
 *
 * Priority:
 *   1. `cf-connecting-ip`   — Cloudflare's canonical client-IP header
 *                              (set by Cloudflare's edge and by the
 *                              `cloudflared` tunnel daemon).
 *   2. `true-client-ip`     — Cloudflare Enterprise / Akamai variant.
 *   3. `x-real-ip`          — Nginx default.
 *   4. `x-forwarded-for`    — RFC 7239 fallback. Uses the *left-most*
 *                              entry (the original client) per the
 *                              standard.
 *   5. `req.ip`             — Express-resolved IP (respects `trust proxy`).
 *   6. `req.socket.remoteAddress` — last-resort raw socket IP.
 *
 * IPv6 addresses prefixed with `::ffff:` (IPv4-mapped) are stripped to
 * their bare IPv4 form so logs read consistently.
 */
export function getClientIp(req: Request): string | undefined {
  const fromHeader =
    pickHeader(req, 'cf-connecting-ip') ??
    pickHeader(req, 'true-client-ip') ??
    pickHeader(req, 'x-real-ip') ??
    pickFirstForwardedFor(req);

  const candidate = fromHeader ?? req.ip ?? req.socket?.remoteAddress;
  return normalize(candidate);
}

function pickHeader(req: Request, name: string): string | undefined {
  const value = req.headers[name];
  if (typeof value === 'string') {
    return value.trim() || undefined;
  }
  if (Array.isArray(value) && value.length > 0) {
    return value[0]?.trim() || undefined;
  }
  return undefined;
}

function pickFirstForwardedFor(req: Request): string | undefined {
  const raw = pickHeader(req, 'x-forwarded-for');
  if (!raw) {
    return undefined;
  }
  // X-Forwarded-For is a comma-separated list: "client, proxy1, proxy2".
  // The original client is the LEFT-MOST entry.
  const first = raw.split(',')[0]?.trim();
  return first || undefined;
}

function normalize(ip: string | undefined | null): string | undefined {
  if (!ip) {
    return undefined;
  }
  const trimmed = ip.trim();
  if (!trimmed) {
    return undefined;
  }
  // IPv4-mapped IPv6 → bare IPv4. e.g. "::ffff:1.2.3.4" → "1.2.3.4"
  if (trimmed.toLowerCase().startsWith('::ffff:')) {
    return trimmed.slice(7);
  }
  return trimmed;
}
