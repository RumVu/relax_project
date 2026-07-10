import { activeLocale, moodLabelByType, moodLabelEnByType, titleize } from './constants';
import { asNumber, asString } from './coercions';

export function localeCode() {
  return activeLocale === 'vi' ? 'vi-VN' : 'en-US';
}

export function toMoodLabel(mood: string | undefined) {
  if (!mood) {
    return undefined;
  }

  return (activeLocale === 'vi' ? moodLabelByType : moodLabelEnByType).get(mood) ?? titleize(mood);
}

export function intensityToPercent(value: number | undefined) {
  if (value === undefined) {
    return undefined;
  }

  return Math.max(0, Math.min(100, Math.round(value * 20)));
}

export function formatDateTime(value: string | undefined) {
  if (!value) {
    return undefined;
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return undefined;
  }

  return date.toLocaleString(localeCode(), {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
}

export function formatDate(value: string | undefined) {
  if (!value) {
    return undefined;
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return undefined;
  }

  return date.toLocaleDateString(localeCode());
}

export function formatClock(value: string | undefined) {
  if (!value) {
    return undefined;
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return undefined;
  }

  return date.toLocaleTimeString(localeCode(), {
    hour: '2-digit',
    minute: '2-digit',
  });
}

export function formatDurationFromSeconds(value: number | undefined) {
  if (value === undefined) {
    return undefined;
  }

  const minutes = Math.max(1, Math.round(value / 60));
  if (minutes >= 60) {
    const hours = Math.floor(minutes / 60);
    const remainingMinutes = minutes % 60;
    return remainingMinutes > 0
      ? `${hours}h ${remainingMinutes}m`
      : `${hours}h`;
  }

  return activeLocale === 'vi' ? `${minutes} phút` : `${minutes} min`;
}

export function formatDurationFromMinutes(value: number | undefined) {
  if (value === undefined) {
    return undefined;
  }

  if (value >= 60) {
    const hours = Math.floor(value / 60);
    const remainingMinutes = value % 60;
    return remainingMinutes > 0 ? `${hours}h ${remainingMinutes}m` : `${hours}h`;
  }

  return activeLocale === 'vi'
    ? `${Math.max(1, Math.round(value))} phút`
    : `${Math.max(1, Math.round(value))} min`;
}

export function zeroDurationLabel() {
  return activeLocale === 'vi' ? '0 phút' : '0 min';
}

export function formatReminderSchedule(item: Record<string, unknown>) {
  const scheduledAt = formatDateTime(asString(item.scheduledAt));
  const repeatRule = asString(item.repeatRule);
  return repeatRule ? `${scheduledAt ?? '--'} • ${repeatRule}` : scheduledAt ?? '--';
}

export function formatCompact(value: number | undefined) {
  if (value === undefined) {
    return '-';
  }

  return new Intl.NumberFormat(localeCode(), {
    notation: 'compact',
    maximumFractionDigits: 1,
  }).format(value);
}

export function formatCurrency(value: number | undefined) {
  if (value === undefined) {
    return '-';
  }

  return new Intl.NumberFormat(localeCode(), {
    style: 'currency',
    currency: 'VND',
    maximumFractionDigits: 0,
  }).format(value);
}

export function formatPercent(value: number | undefined) {
  if (value === undefined) {
    return '-';
  }

  return `${Math.round(value)}%`;
}

export function formatDelta(value: number | undefined) {
  if (value === undefined) {
    return '—';
  }

  const rounded = Math.round(value * 10) / 10;
  return `${rounded > 0 ? '+' : ''}${rounded}%`;
}

export function formatForecastDay(value: string | undefined) {
  if (!value) {
    return undefined;
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return undefined;
  }

    return date.toLocaleDateString(localeCode(), { weekday: 'short' });
}

export function localWeatherGreeting(temp: number | undefined) {
  const hour = new Date().getHours();
  if (activeLocale === 'vi') {
    if (hour >= 23 || hour < 5) return 'Khuya rồi nè';
    if (hour < 11) return 'Chào buổi sáng';
    if (hour < 17) return 'Thời tiết hôm nay';
    if (hour < 21) return 'Chiều tối rồi nè';
    return 'Tối muộn rồi nè';
  }
  if (hour >= 23 || hour < 5) return 'It is late';
  if (hour < 11) return 'Good morning';
  if (hour < 17) return "Today's weather";
  if (hour < 21) return 'Evening weather check';
  return 'Late evening check-in';
}

export function localWeatherSubtitle(temp: number | undefined) {
  if (temp === undefined) {
    return '';
  }
  return activeLocale === 'vi'
    ? `${Math.round(temp)}° ngoài trời.`
    : `${Math.round(temp)}° outside.`;
}
