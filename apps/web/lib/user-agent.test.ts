import { describe, expect, it } from 'vitest';
import {
  describeBrowser,
  describeDevice,
  parseUserAgent,
} from './user-agent';

const MAC_SAFARI =
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/26.5 Safari/605.1.15';
const MAC_CHROME =
  'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Safari/537.36';
const WIN_CHROME =
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/146.0.0.0 Safari/537.36';
const ANDROID_CHROME =
  'Mozilla/5.0 (Linux; Android 14; Pixel 9 Build/MRA58N) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/148.0.0.0 Mobile Safari/537.36';
const IPHONE_SAFARI =
  'Mozilla/5.0 (iPhone; CPU iPhone OS 17_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.4 Mobile/15E148 Safari/604.1';
const FIREFOX =
  'Mozilla/5.0 (X11; Linux x86_64; rv:120.0) Gecko/20100101 Firefox/120.0';
const EDGE =
  'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36 Edg/120.0.0.0';

describe('parseUserAgent', () => {
  it('parses Mac + Safari', () => {
    const p = parseUserAgent(MAC_SAFARI);
    expect(p.device).toBe('Mac · Desktop');
    expect(p.os).toBe('macOS 10.15.7');
    expect(p.browser).toBe('Safari 26');
  });

  it('parses Mac + Chrome', () => {
    const p = parseUserAgent(MAC_CHROME);
    expect(p.device).toBe('Mac · Desktop');
    expect(p.os).toBe('macOS 10.15.7');
    expect(p.browser).toBe('Chrome 148');
  });

  it('parses Windows + Chrome', () => {
    const p = parseUserAgent(WIN_CHROME);
    expect(p.device).toBe('PC · Desktop');
    expect(p.os).toBe('Windows 10 / 11');
    expect(p.browser).toBe('Chrome 146');
  });

  it('parses Android Chrome', () => {
    const p = parseUserAgent(ANDROID_CHROME);
    expect(p.device).toBe('Android Phone');
    expect(p.os).toBe('Android 14');
    expect(p.browser).toBe('Chrome 148');
  });

  it('parses iPhone Safari', () => {
    const p = parseUserAgent(IPHONE_SAFARI);
    expect(p.device).toBe('iPhone');
    expect(p.os).toBe('iOS 17.4');
    expect(p.browser).toBe('Safari 17');
  });

  it('parses Firefox on Linux', () => {
    const p = parseUserAgent(FIREFOX);
    expect(p.device).toBe('Linux · Desktop');
    expect(p.os).toBe('Linux');
    expect(p.browser).toBe('Firefox 120');
  });

  it('parses Edge over Chromium', () => {
    const p = parseUserAgent(EDGE);
    expect(p.browser).toBe('Edge 120');
  });

  it('handles empty UA', () => {
    expect(parseUserAgent('').browser).toBeNull();
    expect(parseUserAgent(undefined).device).toBe('Không rõ thiết bị');
  });

  it('parses curl', () => {
    const p = parseUserAgent('curl/8.7.1');
    expect(p.device).toBe('curl');
    expect(p.browser).toBe('curl 8');
  });
});

describe('describeDevice / describeBrowser', () => {
  it('joins device + os with ·', () => {
    expect(describeDevice(MAC_CHROME)).toBe('Mac · Desktop · macOS 10.15.7');
  });

  it('returns just device when OS unknown', () => {
    expect(describeDevice('Mozilla/5.0 (Unknown)')).toBe('Khác');
  });

  it('returns em-dash for empty browser', () => {
    expect(describeBrowser('')).toBe('—');
  });
});
