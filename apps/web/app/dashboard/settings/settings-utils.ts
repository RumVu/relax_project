import {
  DASHBOARD_THEME_APPLIED_EVENT,
  applyDashboardTheme,
  type DashboardThemeMode,
  type DashboardThemePalette,
} from '@/components/providers/theme-provider';
import type { ThemeMode, CompanionMode, CompanionOptionGroup } from './settings-types';
import { VI_SETTINGS_COPY, EN_SETTINGS_COPY } from './settings-copy';

export function normalizeBirthdayValue(value: string) {
  if (!value || value === '-') {
    return '';
  }

  // Already YYYY-MM-DD — accept as-is so the date input keeps it.
  if (/^\d{4}-\d{2}-\d{2}$/.test(value)) {
    return value;
  }

  // vi-VN locale string "DD/MM/YYYY" — what live-dashboard.formatDate
  // happens to spit out. Parse the parts directly so we don't fall into
  // `new Date("10/3/2003")` which JS interprets as MM/DD/YYYY (US) and
  // would swap day↔month.
  const localeMatch = value.match(/^(\d{1,2})\/(\d{1,2})\/(\d{4})$/);
  if (localeMatch) {
    const [, day, month, year] = localeMatch;
    return `${year}-${month.padStart(2, '0')}-${day.padStart(2, '0')}`;
  }

  // ISO with time (e.g. "2003-03-10T00:00:00Z"). Use UTC parts so a VN
  // +07 browser doesn't roll back/forward a day.
  const parsed = new Date(value);
  if (Number.isNaN(parsed.getTime())) {
    return '';
  }
  const year = parsed.getUTCFullYear();
  const month = String(parsed.getUTCMonth() + 1).padStart(2, '0');
  const day = String(parsed.getUTCDate()).padStart(2, '0');
  return `${year}-${month}-${day}`;
}

export function nextLocalReminderTime() {
  const date = new Date();
  date.setHours(date.getHours() + 1, 0, 0, 0);
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const hour = String(date.getHours()).padStart(2, '0');
  const minute = String(date.getMinutes()).padStart(2, '0');
  return `${year}-${month}-${day}T${hour}:${minute}`;
}

export function formatPlanPrice(price: number, currency: string, locale: 'vi' | 'en') {
  if (price <= 0) {
    return locale === 'en' ? EN_SETTINGS_COPY.free : VI_SETTINGS_COPY.free;
  }

  const intlLocale = locale === 'en' ? 'en-US' : 'vi-VN';
  try {
    return new Intl.NumberFormat(intlLocale, {
      style: 'currency',
      currency,
      maximumFractionDigits: 0,
    }).format(price);
  } catch {
    return `${new Intl.NumberFormat(intlLocale, {
      maximumFractionDigits: 0,
    }).format(price)} ${currency}`;
  }
}

export function toDashboardThemeMode(mode: ThemeMode): DashboardThemeMode {
  return mode.toLowerCase() as DashboardThemeMode;
}

export function dispatchDashboardTheme(
  mode: ThemeMode,
  palette: DashboardThemePalette | null,
) {
  const dashboardMode = toDashboardThemeMode(mode);
  applyDashboardTheme(dashboardMode, palette);
  window.dispatchEvent(
    new CustomEvent(DASHBOARD_THEME_APPLIED_EVENT, {
      detail: {
        mode: dashboardMode,
        palette,
      },
    }),
  );
}

export function modeLabel(mode: CompanionMode, copy: typeof VI_SETTINGS_COPY) {
  if (mode === 'ZODIAC') return copy.modeZodiac;
  if (mode === 'CHINESE_ZODIAC') return copy.modeChineseZodiac;
  if (mode === 'CUSTOM') return copy.modeCustom;
  return copy.modeDefault;
}

export function companionOptionLabel(
  option: CompanionOptionGroup,
  copy: typeof VI_SETTINGS_COPY,
) {
  return modeLabel(option.mode, copy);
}
