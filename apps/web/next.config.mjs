/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  // Allow Next.js dev server (HMR + RSC chunks) to be reached from:
  //   • localhost / 127.0.0.1 (default — implicit)
  //   • the LAN (192.168.* / 10.* / 172.16-31.*) so you can share
  //     http://<LAN-IP>:3233 with someone on the same wifi without
  //     setting up a tunnel
  //   • *.trycloudflare.com fallback for the legacy quick-tunnel flow
  // Production builds (`next build`) ignore this setting entirely.
  allowedDevOrigins: [
    '*.trycloudflare.com',
    '192.168.0.0/16',
    '10.0.0.0/8',
    '172.16.0.0/12',
    // Wildcard fallbacks for hosts that don't match the CIDR notation
    // some Next.js versions don't yet support.
    '192.168.*.*',
    '10.*.*.*',
    '172.16.*.*',
    '172.17.*.*',
    '172.18.*.*',
    '172.19.*.*',
    '172.20.*.*',
    '172.21.*.*',
    '172.22.*.*',
    '172.23.*.*',
    '172.24.*.*',
    '172.25.*.*',
    '172.26.*.*',
    '172.27.*.*',
    '172.28.*.*',
    '172.29.*.*',
    '172.30.*.*',
    '172.31.*.*',
  ],
  async headers() {
    return [
      {
        source: '/:path*',
        headers: [
          {
            key: 'X-Frame-Options',
            value: 'SAMEORIGIN',
          },
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
          {
            key: 'Strict-Transport-Security',
            value: 'max-age=31536000; includeSubDomains',
          },
          {
            key: 'Content-Security-Policy',
            value:
              "default-src 'self'; script-src 'self' 'unsafe-inline' 'unsafe-eval'; style-src 'self' 'unsafe-inline'; img-src 'self' data: blob: https:; media-src 'self' data: blob: https:; connect-src 'self' http://localhost:6823 ws://localhost:6823 https: wss:; frame-ancestors 'self'; base-uri 'self'; form-action 'self'",
          },
          {
            key: 'Permissions-Policy',
            value: 'camera=(), microphone=(), geolocation=(self)',
          },
        ],
      },
    ];
  },
};

export default nextConfig;
