'use client';

/**
 * i18n provider — lightweight, không phụ thuộc next-intl.
 *
 * Locale lưu ở:
 *   - localStorage `digital-break:locale`
 *   - cookie `dcb_locale` (để SSR / middleware có thể đọc nếu cần sau này)
 *
 * Mặc định: Tiếng Việt. Khi đổi locale, document.documentElement.lang
 * được cập nhật để các thuộc tính accessibility chính xác.
 */

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useState,
} from 'react';
import {
  DEFAULT_LOCALE,
  DICTIONARIES,
  LOCALES,
  Locale,
  TranslationKey,
} from './dictionaries';

const LOCALE_STORAGE_KEY = 'digital-break:locale';
const LOCALE_COOKIE_KEY = 'dcb_locale';

interface I18nContextValue {
  locale: Locale;
  setLocale: (locale: Locale) => void;
  t: (key: TranslationKey, params?: Record<string, string | number>) => string;
}

const I18nContext = createContext<I18nContextValue | null>(null);

function readInitialLocale(): Locale {
  if (typeof window === 'undefined') return DEFAULT_LOCALE;
  try {
    const fromQuery = new URLSearchParams(window.location.search).get('locale')
      ?? new URLSearchParams(window.location.search).get('lang');
    if (fromQuery && (LOCALES as string[]).includes(fromQuery)) {
      return fromQuery as Locale;
    }
    const stored = window.localStorage.getItem(LOCALE_STORAGE_KEY);
    if (stored && (LOCALES as string[]).includes(stored)) {
      return stored as Locale;
    }
    const fromCookie = document.cookie
      .split('; ')
      .find((row) => row.startsWith(`${LOCALE_COOKIE_KEY}=`))
      ?.split('=')[1];
    if (fromCookie && (LOCALES as string[]).includes(fromCookie)) {
      return fromCookie as Locale;
    }
    // Fall back to browser language if it starts with one of our locales.
    const nav = navigator.language?.slice(0, 2).toLowerCase();
    if (nav && (LOCALES as string[]).includes(nav)) {
      return nav as Locale;
    }
  } catch {
    // localStorage may throw in private mode — ignore.
  }
  return DEFAULT_LOCALE;
}

function interpolate(
  template: string,
  params?: Record<string, string | number>,
): string {
  if (!params) return template;
  return template.replace(/\{\{(\w+)\}\}/g, (_, key: string) =>
    params[key] !== undefined ? String(params[key]) : `{{${key}}}`,
  );
}

export function I18nProvider({ children }: { children: React.ReactNode }) {
  // Start with DEFAULT_LOCALE on first render (SSR-safe), then sync from
  // localStorage in the mount effect — avoids hydration mismatch.
  const [locale, setLocaleState] = useState<Locale>(DEFAULT_LOCALE);

  useEffect(() => {
    // SSR-safe: read once on mount and apply. The set-state-in-effect
    // is intentional — we can't read localStorage during render.
    const initial = readInitialLocale();
    if (initial !== DEFAULT_LOCALE) {
      // eslint-disable-next-line react-hooks/set-state-in-effect
      setLocaleState(initial);
    }
    if (typeof document !== 'undefined') {
      document.documentElement.lang = initial;
    }
  }, []);

  const setLocale = useCallback((next: Locale) => {
    setLocaleState(next);
    if (typeof window !== 'undefined') {
      try {
        window.localStorage.setItem(LOCALE_STORAGE_KEY, next);
        // 1-year cookie so middleware/SSR can pick it up later.
        document.cookie = `${LOCALE_COOKIE_KEY}=${next}; Path=/; Max-Age=31536000; SameSite=Lax`;
        document.documentElement.lang = next;
      } catch {
        // Ignored — private mode or sandboxed iframe.
      }
    }
  }, []);

  const value = useMemo<I18nContextValue>(() => {
    const dictionary = DICTIONARIES[locale];
    return {
      locale,
      setLocale,
      t: (key, params) => {
        const template = dictionary[key];
        // Missing key surfaces visibly so we catch it during QA.
        if (template === undefined) return `‹${key}›`;
        return interpolate(template, params);
      },
    };
  }, [locale, setLocale]);

  return <I18nContext.Provider value={value}>{children}</I18nContext.Provider>;
}

/**
 * Subscribe a component to the current locale + translator.
 * Returns a stable `{ t, locale, setLocale }` triple.
 */
export function useTranslation(): I18nContextValue {
  const ctx = useContext(I18nContext);
  if (!ctx) {
    // Standalone fallback — useful inside test renders without provider.
    return {
      locale: DEFAULT_LOCALE,
      setLocale: () => undefined,
      t: (key) => DICTIONARIES[DEFAULT_LOCALE][key] ?? `‹${key}›`,
    };
  }
  return ctx;
}
