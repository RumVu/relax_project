import { userDashboardData } from '@/lib/dashboard-data';
import type { Locale } from '@/lib/i18n/dictionaries';

export type UserDashboardData = typeof userDashboardData;
export type DashboardQuery = Record<string, string | number | boolean | undefined>;

export type PageResponse<T> = {
  items?: T[];
  total?: number;
};

export type MoodOption = (typeof userDashboardData.moodOptions)[number];

export const moodOptionByType = new Map<string, MoodOption>(
  userDashboardData.moodOptions.map((option) => [option.type, option]),
);

export const moodLabelByType = new Map<string, string>(
  userDashboardData.moodOptions.map((option) => [option.type, option.label]),
);
export const moodLabelEnByType = new Map<string, string>(
  userDashboardData.moodOptions.map((option) => [option.type, titleize(option.type)]),
);

/** Mutable locale state shared across all dashboard modules. */
export let activeLocale: Locale = 'vi';

export function setActiveLocale(locale: Locale) {
  activeLocale = locale;
}

export function titleize(value: string) {
  return value
    .toLowerCase()
    .split('_')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}
