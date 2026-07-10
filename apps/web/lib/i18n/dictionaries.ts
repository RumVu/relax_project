/**
 * Tiếng Việt là ngôn ngữ mặc định (KHÔNG viết tắt, KHÔNG chêm tiếng Anh).
 * English là ngôn ngữ thứ hai.
 *
 * Quy ước key: namespace.path.in.dot (ví dụ `nav.overview`,
 * `accountMenu.logout`). Một key mới phải có cả 2 ngôn ngữ — TypeScript
 * sẽ chặn build nếu thiếu (xem type `Locale` & `Dictionary`).
 *
 * Placeholder {{name}} được hỗ trợ qua hàm `t(key, { name })`.
 */

// Re-export locale constants so existing `import { Locale } from './dictionaries'` keeps working.
export {
  type Locale,
  LOCALES,
  DEFAULT_LOCALE,
  LOCALE_LABELS,
  LOCALE_SHORT,
} from './locale';

import type { Locale } from './locale';
import { viCore, enCore } from './dict-core';
import { viWeather, enWeather } from './dict-weather';
import { viMood, enMood } from './dict-mood';
import { viAdmin, enAdmin } from './dict-admin';
import { viSettings, enSettings } from './dict-settings';
import { viContent, enContent } from './dict-content';

const vi = {
  ...viCore,
  ...viWeather,
  ...viMood,
  ...viAdmin,
  ...viSettings,
  ...viContent,
} as const;

const en: Record<keyof typeof vi, string> = {
  ...enCore,
  ...enWeather,
  ...enMood,
  ...enAdmin,
  ...enSettings,
  ...enContent,
};

export type TranslationKey = keyof typeof vi;
export type Dictionary = Record<TranslationKey, string>;

export const DICTIONARIES: Record<Locale, Dictionary> = {
  vi,
  en,
};
