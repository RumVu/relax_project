import { describe, expect, it } from 'vitest';
import { getReadableTextColor, isReadable } from './contrast';

describe('getReadableTextColor', () => {
  it('keeps a high-contrast preferred colour', () => {
    expect(getReadableTextColor('#ffffff', '#0f172a')).toBe('#0f172a');
    expect(getReadableTextColor('#020617', '#ffffff')).toBe('#ffffff');
  });

  it('swaps to white when dark text is on a dark background', () => {
    // The reported HÌNH 2 case: dark theme card with dark ink text.
    expect(getReadableTextColor('#020617', '#261D55')).toBe('#f8fafc');
    expect(getReadableTextColor('#111827', '#0f172a')).toBe('#f8fafc');
  });

  it('swaps to near-black when light text is on a light background', () => {
    expect(getReadableTextColor('#ffffff', '#fafafa')).toBe('#0f172a');
    expect(getReadableTextColor('#f8fafc', '#e2e8f0')).toBe('#0f172a');
  });

  it('falls back when preferred is not provided', () => {
    expect(getReadableTextColor('#020617')).toBe('#f8fafc');
    expect(getReadableTextColor('#ffffff')).toBe('#0f172a');
  });

  it('handles 3-digit hex', () => {
    expect(getReadableTextColor('#fff', '#000')).toBe('#000');
    expect(getReadableTextColor('#000', '#fff')).toBe('#fff');
  });

  it('handles rgb()/rgba()', () => {
    expect(getReadableTextColor('rgb(0, 0, 0)', 'rgb(20, 20, 20)')).toBe(
      '#f8fafc',
    );
    expect(getReadableTextColor('rgba(255, 255, 255, 0.9)', '#0f172a')).toBe(
      '#0f172a',
    );
  });

  it('returns the preferred value when the background is unparseable', () => {
    expect(getReadableTextColor('not-a-color', '#abcdef')).toBe('#abcdef');
  });
});

describe('isReadable', () => {
  it('returns true for high-contrast pairs', () => {
    expect(isReadable('#ffffff', '#000000')).toBe(true);
    expect(isReadable('#0f172a', '#f8fafc')).toBe(true);
  });

  it('returns false for low-contrast pairs', () => {
    expect(isReadable('#020617', '#261D55')).toBe(false);
    expect(isReadable('#ffffff', '#fafafa')).toBe(false);
  });

  it('returns true (permissive) when either side is unparseable', () => {
    expect(isReadable('not-a-color', '#000000')).toBe(true);
  });
});
