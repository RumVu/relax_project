/**
 * Locale constants — no dependency on dictionaries.
 */

export type Locale = 'vi' | 'en';
export const LOCALES: Locale[] = ['vi', 'en'];
export const DEFAULT_LOCALE: Locale = 'vi';

export const LOCALE_LABELS: Record<Locale, string> = {
  vi: 'Tiếng Việt',
  en: 'English',
};

export const LOCALE_SHORT: Record<Locale, string> = {
  vi: 'VI',
  en: 'EN',
};
