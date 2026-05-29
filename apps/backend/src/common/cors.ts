/**
 * Decides whether a CORS `Origin` header should be allowed.
 *
 * Allow rules:
 * 1. Exact match against the configured allow-list (always).
 * 2. Dev-only conveniences (skipped in production):
 *    - http(s)://localhost or 127.0.0.1 on any port,
 *    - private LAN ranges (192.168.x.x, 10.x.x.x, 172.16-31.x.x) on
 *      any port — so you can share http://<your-LAN-IP>:3233 with a
 *      teammate or phone on the same wifi without a tunnel,
 *    - any *.trycloudflare.com host (legacy quick-tunnel fallback),
 *    - wildcard `*` if explicitly opted in via CORS_ORIGINS.
 *
 * All dev carve-outs are intentionally non-prod only: in production we
 * want CORS_ORIGINS to be an explicit allow-list.
 */
export function isAllowedOrigin(
  origin: string,
  allowedOrigins: string[],
  isProduction: boolean,
): boolean {
  if (allowedOrigins.includes(origin)) {
    return true;
  }

  if (isProduction) {
    return false;
  }

  if (/^https?:\/\/(localhost|127\.0\.0\.1)(:\d+)?$/.test(origin)) {
    return true;
  }

  // RFC 1918 private IPv4 ranges — the docker-bridge & wifi LAN cases.
  if (isPrivateIpOrigin(origin)) {
    return true;
  }

  if (/^https:\/\/[a-z0-9-]+\.trycloudflare\.com$/.test(origin)) {
    return true;
  }

  return allowedOrigins.includes('*');
}

function isPrivateIpOrigin(origin: string): boolean {
  const match = origin.match(/^https?:\/\/(\d+\.\d+\.\d+\.\d+)(?::\d+)?$/);
  if (!match) {
    return false;
  }
  const ip = match[1]!;
  const parts = ip.split('.').map(Number);
  if (parts.length !== 4 || parts.some((part) => Number.isNaN(part) || part < 0 || part > 255)) {
    return false;
  }
  const [a, b] = parts as [number, number, number, number];
  // 192.168.0.0/16
  if (a === 192 && b === 168) return true;
  // 10.0.0.0/8
  if (a === 10) return true;
  // 172.16.0.0/12
  if (a === 172 && b >= 16 && b <= 31) return true;
  return false;
}
