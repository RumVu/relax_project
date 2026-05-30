/**
 * Tiny User-Agent parser dùng cho UI "Lịch sử đăng nhập".
 *
 * Mirror logic của `summariseUserAgent` ở backend (apps/backend/src/auth/
 * helpers/auth.helpers.ts) — không pull thêm 1 dep nặng cho frontend.
 *
 * Output gồm 4 trường:
 *   - deviceType: Desktop / Mobile / Tablet / Khác
 *   - os         + osVersion (nếu detect được)
 *   - browser    + browserVersion (nếu detect được)
 *   - raw        (UA gốc để debug, copy-to-clipboard)
 */

export interface ParsedUserAgent {
  deviceType: 'Desktop' | 'Mobile' | 'Tablet' | 'Khác';
  os: string;
  osVersion: string | null;
  browser: string;
  browserVersion: string | null;
  raw: string;
}

export function parseUserAgent(rawInput?: string | null): ParsedUserAgent {
  const raw = (rawInput ?? '').trim();
  if (!raw) {
    return {
      deviceType: 'Khác',
      os: 'Không xác định',
      osVersion: null,
      browser: 'Không xác định',
      browserVersion: null,
      raw: '',
    };
  }

  const lower = raw.toLowerCase();

  // ---- Device type ----
  let deviceType: ParsedUserAgent['deviceType'] = 'Desktop';
  if (/ipad/.test(lower)) deviceType = 'Tablet';
  else if (/(android(?!.*mobile))/.test(lower)) deviceType = 'Tablet';
  else if (/(mobile|iphone|android|ipod)/.test(lower)) deviceType = 'Mobile';
  else if (/(macintosh|windows nt|linux|x11|cros)/.test(lower)) deviceType = 'Desktop';
  else if (/curl|wget|axios|node-fetch|httpie/.test(lower)) deviceType = 'Khác';

  // ---- OS + version ----
  let os = 'Khác';
  let osVersion: string | null = null;

  if (/iphone|ipod/.test(lower)) {
    os = 'iOS';
    osVersion = (raw.match(/OS\s+([\d_]+)/) ?? [])[1]?.replace(/_/g, '.') ?? null;
  } else if (/ipad/.test(lower)) {
    os = 'iPadOS';
    osVersion = (raw.match(/OS\s+([\d_]+)/) ?? [])[1]?.replace(/_/g, '.') ?? null;
  } else if (/android/.test(lower)) {
    os = 'Android';
    osVersion = (raw.match(/Android\s+([\d.]+)/) ?? [])[1] ?? null;
  } else if (/windows nt/.test(lower)) {
    // Windows NT 10.0 → "Windows 10/11", NT 6.3 → "Windows 8.1" …
    const nt = (raw.match(/Windows NT\s+([\d.]+)/) ?? [])[1] ?? '';
    os = 'Windows';
    osVersion =
      nt === '10.0' ? '10/11' : nt === '6.3' ? '8.1' : nt === '6.2' ? '8' : nt === '6.1' ? '7' : nt || null;
  } else if (/mac os x|macintosh/.test(lower)) {
    os = 'macOS';
    osVersion =
      (raw.match(/Mac OS X\s+([\d_]+)/) ?? [])[1]?.replace(/_/g, '.') ?? null;
  } else if (/cros/.test(lower)) {
    os = 'ChromeOS';
  } else if (/linux|x11/.test(lower)) {
    os = 'Linux';
  } else if (/curl/.test(lower)) {
    os = 'CLI (curl)';
  }

  // ---- Browser + version (order matters: Edge before Chrome, Coc Coc before Chrome, etc) ----
  let browser = 'Khác';
  let browserVersion: string | null = null;

  const match = (re: RegExp): string | null => (raw.match(re) ?? [])[1] ?? null;

  if (/edg\//i.test(raw)) {
    browser = 'Microsoft Edge';
    browserVersion = match(/Edg\/([\d.]+)/i);
  } else if (/coc_coc_browser|coccoc/i.test(raw)) {
    browser = 'Cốc Cốc';
    browserVersion = match(/coc_coc_browser\/([\d.]+)/i);
  } else if (/brave/i.test(raw)) {
    browser = 'Brave';
    browserVersion = match(/Brave\/([\d.]+)/i) ?? match(/Chrome\/([\d.]+)/i);
  } else if (/opr\/|opera/i.test(raw)) {
    browser = 'Opera';
    browserVersion = match(/OPR\/([\d.]+)/i) ?? match(/Opera\/([\d.]+)/i);
  } else if (/samsungbrowser/i.test(raw)) {
    browser = 'Samsung Internet';
    browserVersion = match(/SamsungBrowser\/([\d.]+)/i);
  } else if (/firefox|fxios/i.test(raw)) {
    browser = 'Firefox';
    browserVersion = match(/(?:Firefox|FxiOS)\/([\d.]+)/i);
  } else if (/crios/i.test(raw)) {
    browser = 'Chrome (iOS)';
    browserVersion = match(/CriOS\/([\d.]+)/i);
  } else if (/chrome/i.test(raw)) {
    browser = 'Chrome';
    browserVersion = match(/Chrome\/([\d.]+)/i);
  } else if (/safari/i.test(raw)) {
    browser = 'Safari';
    browserVersion = match(/Version\/([\d.]+)/i);
  } else if (/curl/i.test(raw)) {
    browser = 'curl';
    browserVersion = match(/curl\/([\d.]+)/i);
  }

  return { deviceType, os, osVersion, browser, browserVersion, raw };
}

/** Compact "Chrome 147 trên macOS 14.5" label. */
export function formatUserAgentSummary(parsed: ParsedUserAgent): string {
  const browser = parsed.browserVersion
    ? `${parsed.browser} ${parsed.browserVersion.split('.')[0]}`
    : parsed.browser;
  const os = parsed.osVersion ? `${parsed.os} ${parsed.osVersion}` : parsed.os;
  return `${browser} trên ${os}`;
}
