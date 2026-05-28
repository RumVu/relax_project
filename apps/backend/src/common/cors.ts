/**
 * Decides whether a CORS `Origin` header should be allowed.
 *
 * Allow rules:
 * 1. Exact match against the configured allow-list (always).
 * 2. Dev-only conveniences (skipped in production):
 *    - http(s)://localhost or 127.0.0.1 on any port,
 *    - any *.trycloudflare.com host (Cloudflare quick tunnels — handy for
 *      sharing a dev backend with a mobile device or remote teammate),
 *    - wildcard `*` if explicitly opted in via CORS_ORIGINS.
 *
 * The trycloudflare carve-out is intentionally limited to non-prod: in
 * production we want CORS_ORIGINS to be an explicit allow-list.
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

  if (/^https:\/\/[a-z0-9-]+\.trycloudflare\.com$/.test(origin)) {
    return true;
  }

  return allowedOrigins.includes('*');
}
