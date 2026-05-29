/**
 * Tiny, dependency-free user-agent parser. Extracts a friendly
 * "Device" + "Browser" string for the Sessions table so the admin
 * doesn't have to read the raw
 *   "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)
 *    AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.5 Safari/605.1.15"
 * blob to figure out what device made the request.
 *
 * Returns a `null` field when the UA is missing/unrecognised so callers
 * can fall back to a placeholder.
 */
export type ParsedUserAgent = {
  device: string; // "Mac · Desktop" / "iPhone" / "Android Phone"
  os: string | null; // "macOS 10.15", "Windows 11", "Android 14", …
  browser: string | null; // "Chrome 148", "Safari 17.4"
  raw: string;
};

export function parseUserAgent(ua: string | null | undefined): ParsedUserAgent {
  const raw = (ua ?? '').trim();
  if (!raw) {
    return { device: 'Không rõ thiết bị', os: null, browser: null, raw: '' };
  }

  const lower = raw.toLowerCase();

  // ---- OS ----------------------------------------------------------------
  let os: string | null = null;
  let device = 'Khác';

  if (/iphone/.test(lower)) {
    const v = raw.match(/iphone os ([\d_]+)/i)?.[1]?.replace(/_/g, '.');
    os = v ? `iOS ${v}` : 'iOS';
    device = 'iPhone';
  } else if (/ipad/.test(lower)) {
    const v = raw.match(/cpu os ([\d_]+)/i)?.[1]?.replace(/_/g, '.');
    os = v ? `iPadOS ${v}` : 'iPadOS';
    device = 'iPad';
  } else if (/android/.test(lower)) {
    const v = raw.match(/android ([\d.]+)/i)?.[1];
    os = v ? `Android ${v}` : 'Android';
    device = /mobile/.test(lower) ? 'Android Phone' : 'Android Tablet';
  } else if (/mac os x|macintosh/.test(lower)) {
    const v = raw
      .match(/mac os x ([\d_]+)/i)?.[1]
      ?.replace(/_/g, '.');
    os = v ? `macOS ${v}` : 'macOS';
    device = 'Mac · Desktop';
  } else if (/windows/.test(lower)) {
    const m = raw.match(/windows nt ([\d.]+)/i)?.[1];
    os = m ? `Windows ${mapWindowsVersion(m)}` : 'Windows';
    device = 'PC · Desktop';
  } else if (/linux/.test(lower)) {
    os = 'Linux';
    device = 'Linux · Desktop';
  } else if (/cros/.test(lower)) {
    os = 'Chrome OS';
    device = 'Chromebook';
  } else if (/curl\//.test(lower)) {
    os = 'CLI';
    device = 'curl';
  }

  // ---- Browser -----------------------------------------------------------
  // Order matters: more-specific UAs (Edge/Opera/Brave) must come before the
  // generic "Chrome" / "Safari" matches.
  let browser: string | null = null;
  const tests: Array<[RegExp, string]> = [
    [/edg\/([\d.]+)/i, 'Edge'],
    [/edga\/([\d.]+)/i, 'Edge Android'],
    [/edgios\/([\d.]+)/i, 'Edge iOS'],
    [/opr\/([\d.]+)/i, 'Opera'],
    [/opera\/([\d.]+)/i, 'Opera'],
    [/firefox\/([\d.]+)/i, 'Firefox'],
    [/fxios\/([\d.]+)/i, 'Firefox iOS'],
    [/samsungbrowser\/([\d.]+)/i, 'Samsung Internet'],
    [/crios\/([\d.]+)/i, 'Chrome iOS'],
    [/chrome\/([\d.]+)/i, 'Chrome'],
    [/version\/([\d.]+).+safari/i, 'Safari'],
    [/safari\/([\d.]+)/i, 'Safari'],
    [/curl\/([\d.]+)/i, 'curl'],
    [/^([\w-]+)\/([\d.]+)/, ''], // last resort: take whatever ToolName/version
  ];
  for (const [pattern, name] of tests) {
    const match = raw.match(pattern);
    if (match) {
      const version = trimVersion(match[name ? 1 : 2]);
      const label = name || match[1] || 'Unknown';
      browser = version ? `${label} ${version}` : label;
      break;
    }
  }

  return { device, os, browser, raw };
}

function mapWindowsVersion(nt: string): string {
  // Windows NT version → marketing name mapping.
  switch (nt) {
    case '10.0':
      return '10 / 11';
    case '6.3':
      return '8.1';
    case '6.2':
      return '8';
    case '6.1':
      return '7';
    case '6.0':
      return 'Vista';
    default:
      return `NT ${nt}`;
  }
}

function trimVersion(v?: string): string {
  if (!v) return '';
  // Keep major.minor only — "148.0.0.0" → "148"
  return v.split('.').slice(0, 1).join('.');
}

/**
 * Convenience helpers for the Sessions table — returns one compact
 * label per column so the column rendering stays trivial.
 */
export function describeDevice(ua: string | null | undefined): string {
  const parsed = parseUserAgent(ua);
  if (!parsed.os && !parsed.browser) {
    return parsed.device;
  }
  if (parsed.os) {
    return `${parsed.device} · ${parsed.os}`;
  }
  return parsed.device;
}

export function describeBrowser(ua: string | null | undefined): string {
  const parsed = parseUserAgent(ua);
  return parsed.browser ?? '—';
}
