import { describe, expect, it } from 'vitest';
import { adminNav, primaryNav } from './constants';

describe('navigation constants', () => {
  describe('primaryNav', () => {
    it('exposes the dashboard surfaces in a stable order', () => {
      expect(primaryNav.map((item) => item.href)).toEqual([
        '/dashboard',
        '/dashboard/mood',
        '/dashboard/breaks',
        '/dashboard/journal',
        '/dashboard/analytics',
        '/dashboard/settings',
      ]);
    });

    it('gives every item a non-empty label', () => {
      for (const item of primaryNav) {
        expect(item.label.trim().length).toBeGreaterThan(0);
      }
    });

    it('only uses /dashboard hrefs', () => {
      for (const item of primaryNav) {
        expect(item.href.startsWith('/dashboard')).toBe(true);
      }
    });
  });

  describe('adminNav', () => {
    it('only uses /admin hrefs', () => {
      for (const item of adminNav) {
        expect(item.href.startsWith('/admin')).toBe(true);
      }
    });

    it('exposes every catalog admin surface', () => {
      const hrefs = adminNav.map((item) => item.href);
      for (const expected of [
        '/admin/users',
        '/admin/logs',
        '/admin/quotes',
        '/admin/sounds',
        '/admin/exercises',
        '/admin/themes',
        '/admin/onboarding',
        '/admin/companion-assets',
        '/admin/companion-messages',
      ]) {
        expect(hrefs).toContain(expected);
      }
    });

    it('has no duplicate hrefs', () => {
      const hrefs = adminNav.map((item) => item.href);
      expect(new Set(hrefs).size).toBe(hrefs.length);
    });
  });
});
