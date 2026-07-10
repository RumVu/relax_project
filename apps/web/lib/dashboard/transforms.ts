import { getStoredAccessToken, getStoredSessionId } from '@/lib/api';
import { activeLocale, moodOptionByType, titleize } from './constants';
import {
  asArray,
  asBoolean,
  asNumber,
  asRecord,
  asString,
  asStringArray,
  readReliefPercent,
  truncate,
} from './coercions';
import {
  formatClock,
  formatCompact,
  formatCurrency,
  formatDate,
  formatDateTime,
  formatDelta,
  formatDurationFromMinutes,
  formatDurationFromSeconds,
  formatForecastDay,
  formatPercent,
  formatReminderSchedule,
  localWeatherGreeting,
  localWeatherSubtitle,
  toMoodLabel,
  zeroDurationLabel,
} from './formatters';

// ---------------------------------------------------------------------------
// Mood transforms
// ---------------------------------------------------------------------------

export function buildDistribution(
  items: Array<Record<string, unknown>> | undefined,
  total?: number,
) {
  if (!items?.length) {
    return undefined;
  }

  const resolvedTotal =
    total ??
    items.reduce((sum, item) => sum + (asNumber(item.count) ?? 0), 0);

  return items.map((item) => {
    const count = asNumber(item.count) ?? 0;
    return {
      mood:
        toMoodLabel(asString(item.mood)) ??
        asString(item.label) ??
        'Unknown',
      count,
      percent:
        asNumber(item.percent) ??
        (resolvedTotal > 0 ? Math.round((count / resolvedTotal) * 100) : 0),
    };
  });
}

export function mapMoodOptions(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => {
    const type = asString(item.mood);
    const fallback = type ? moodOptionByType.get(type) : undefined;

    return {
      type: type ?? fallback?.type ?? 'NEUTRAL',
      label:
        toMoodLabel(type) ??
        asString(item.label) ??
        fallback?.label ??
        (activeLocale === 'vi' ? 'Bình thường' : 'Neutral'),
      icon: fallback?.icon ?? 'sparkles',
      value:
        asNumber(item.value) ??
        asNumber(item.score) ??
        fallback?.value ??
        50,
      color: fallback?.color ?? '#7357f6',
    };
  });
}

export function mapTimeline(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => ({
    label: asString(item.label) ?? '--',
    date: asString(item.date) ?? '',
    moodScore: asNumber(item.moodScore) ?? 0,
    stressScore:
      asNumber(item.stressRate) ?? asNumber(item.stressScore) ?? 0,
    relaxMinutes: asNumber(item.relaxMinutes) ?? 0,
    journals: asNumber(item.journals) ?? 0,
  }));
}

export function mapMoodHistory(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => ({
    id: asString(item.id) ?? crypto.randomUUID(),
    createdAt: formatDateTime(asString(item.createdAt)) ?? '--',
    moodType: asString(item.mood) ?? 'NEUTRAL',
    mood: toMoodLabel(asString(item.mood)) ?? 'Unknown',
    note:
      truncate(asString(item.note), 120) ??
      truncate(asString(item.description), 120) ??
      (activeLocale === 'vi' ? 'Không có ghi chú' : 'No note'),
    intensity: asNumber(item.intensity) ?? 0,
  }));
}

export function mapWeeklyStats(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => ({
    weekStart: formatDate(asString(item.weekStart)) ?? '--',
    avgScore: asNumber(item.avgScore) ?? 0,
    stressReducePct: asNumber(item.stressReducePct) ?? 0,
    streakDays: asNumber(item.streakDays) ?? 0,
    dominantMood: toMoodLabel(asString(item.dominantMood)) ?? 'Unknown',
  }));
}

// ---------------------------------------------------------------------------
// Relax / Activity transforms
// ---------------------------------------------------------------------------

export function mapRelaxActivities(
  catalogItems: Array<Record<string, unknown>> | undefined,
  statsItems: Array<Record<string, unknown>> | undefined,
) {
  if (!catalogItems?.length) {
    return undefined;
  }

  return catalogItems.map((item, index) => {
    const type = asString(item.type) ?? 'MUSIC';
    const matched = statsItems?.find((entry) => asString(entry.type) === type);

    return {
      id: asString(item.id) ?? String(type || index),
      type,
      title:
        asString(item.title) ??
        asString(item.name) ??
        titleize(type),
      subtitle:
        asString(item.description) ??
        asString(item.subtitle) ??
        (activeLocale === 'vi' ? 'Hoạt động thư giãn' : 'Relax activity'),
      duration:
        formatDurationFromMinutes(
          asNumber(item.defaultDurationMinutes) ?? asNumber(item.durationMinutes),
        ) ??
        asString(item.durationLabel) ??
        formatDurationFromSeconds(asNumber(item.durationSeconds)) ??
        zeroDurationLabel(),
      resources: (asArray<Record<string, unknown>>(item.resources) ?? []).map(
        (resource) => ({
          id: asString(resource.id) ?? crypto.randomUUID(),
          title: asString(resource.title) ?? asString(resource.name) ?? titleize(type),
          category: asString(resource.category) ?? type,
          duration: asNumber(resource.duration),
          soundUrl: asString(resource.soundUrl) ?? asString(resource.audioUrl),
          imageUrl: asString(resource.imageUrl) ?? asString(resource.coverUrl),
        }),
      ),
      sessions: asNumber(matched?.count) ?? 0,
      relief: readReliefPercent(matched) ?? readReliefPercent(item) ?? 0,
    };
  });
}

export function mapFavoriteActivities(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => ({
    activityType: asString(item.type) ?? 'MUSIC',
    label: asString(item.title) ?? (activeLocale === 'vi' ? 'Hoạt động' : 'Activity'),
    totalDurationSeconds: asNumber(item.durationSeconds) ?? 0,
    sessions: asNumber(item.count) ?? 0,
  }));
}

export function mapRecentMoments(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => ({
    title: asString(item.title) ?? 'Session',
    time: formatClock(asString(item.endedAt) ?? asString(item.startedAt)) ?? '--:--',
    duration:
      formatDurationFromSeconds(asNumber(item.durationSeconds)) ?? zeroDurationLabel(),
    relief: readReliefPercent(item) ?? 0,
  }));
}

// ---------------------------------------------------------------------------
// Journal transforms
// ---------------------------------------------------------------------------

export function mapJournalRecent(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => ({
    id: asString(item.id) ?? crypto.randomUUID(),
    title: asString(item.title) ?? (activeLocale === 'vi' ? 'Nhật ký' : 'Journal'),
    content: asString(item.content) ?? '',
    moodType: asString(item.mood) ?? 'NEUTRAL',
    mood: toMoodLabel(asString(item.mood)) ?? 'Neutral',
    tags: asStringArray(item.tags),
    excerpt:
      truncate(asString(item.content), 120) ??
      truncate(asString(item.note), 120) ??
      '',
    createdAt: formatDateTime(asString(item.createdAt)) ?? '--',
    favorite: asBoolean(item.isFavorite) ?? false,
  }));
}

export function mapJournalMoodStats(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => ({
    mood: toMoodLabel(asString(item.mood)) ?? 'Unknown',
    count: asNumber(item.count) ?? 0,
  }));
}

export function mapRecommendations(items: unknown[] | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items
    .map((item) => {
      if (typeof item === 'string') {
        return item;
      }

      if (item && typeof item === 'object') {
        const record = item as Record<string, unknown>;
        return (
          asString(record.message) ??
          asString(record.title) ??
          asString(record.label) ??
          asString(record.description)
        );
      }

      return undefined;
    })
    .filter((item): item is string => Boolean(item));
}

// ---------------------------------------------------------------------------
// Settings transforms
// ---------------------------------------------------------------------------

export function mapSessions(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  const currentSessionId = getCurrentSessionId();

  return items.map((item, index) => ({
    id: asString(item.id) ?? crypto.randomUUID(),
    device: asString(item.userAgent) ?? `Session ${index + 1}`,
    ipAddress: formatIpAddress(asString(item.ipAddress)),
    createdAt: formatDateTime(asString(item.createdAt)) ?? '-',
    expiresAt: formatDate(asString(item.expiresAt)) ?? '-',
    current: Boolean(currentSessionId && asString(item.id) === currentSessionId),
  }));
}

export function formatIpAddress(ipAddress?: string) {
  const value = ipAddress?.trim();

  if (!value) {
    return activeLocale === 'vi' ? 'Chưa ghi nhận' : 'Not recorded';
  }

  if (value === '::1' || value === '127.0.0.1') {
    return `${value} (local)`;
  }

  if (value === '::ffff:127.0.0.1') {
    return '127.0.0.1 (local)';
  }

  if (value.startsWith('::ffff:')) {
    return value.replace('::ffff:', '');
  }

  return value;
}

export function mapReminderTimes(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items
    .map((item) => formatClock(asString(item.scheduledAt)))
    .filter((item): item is string => Boolean(item));
}

export function mapReminderTable(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  // Newest first — most recently created reminder is what the user just
  // pressed "Tạo reminder" on, so it should land at the TOP of the table
  // instead of being appended somewhere off-screen at the bottom.
  const sorted = [...items].sort((a, b) => {
    const aTs = Date.parse(asString(a.createdAt) ?? '') || 0;
    const bTs = Date.parse(asString(b.createdAt) ?? '') || 0;
    return bTs - aTs;
  });

  return sorted.map((item) => ({
    id: asString(item.id) ?? crypto.randomUUID(),
    type: asString(item.type) ?? 'CUSTOM',
    title: asString(item.title) ?? 'Reminder',
    schedule: formatReminderSchedule(item),
    active: asBoolean(item.isActive) ?? false,
  }));
}

export function mapBilling(subscription?: Record<string, unknown>) {
  if (!subscription) {
    return {
      planName: activeLocale === 'vi' ? 'Chưa có gói' : 'No plan yet',
      status: 'inactive',
      renewal: '—',
    };
  }

  return {
    planName: asString(subscription.planName) ?? 'FREE',
    status: asString(subscription.status)?.toLowerCase() ?? 'active',
    renewal: formatDate(asString(subscription.endDate)) ?? '-',
  };
}

export function mapPayments(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return [];
  }

  return items.map((item) => ({
    id: asString(item.id) ?? '',
    amount: asNumber(item.amount) ?? 0,
    currency: asString(item.currency) ?? 'VND',
    status: asString(item.status) ?? 'PENDING',
    provider: asString(item.provider) ?? 'MANUAL',
    method: asString(item.method) ?? null,
    externalPaymentId: asString(item.externalPaymentId) ?? null,
    description: asString(item.description) ?? null,
    createdAt: formatDateTime(asString(item.createdAt)) ?? '--',
  }));
}

export function mapPushDevices(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return [];
  }

  return items.map((item) => ({
    id: asString(item.id) ?? crypto.randomUUID(),
    label:
      asString(item.deviceName) ??
      asString(item.deviceId) ??
      asString(item.platform) ??
      'Device',
    platform: asString(item.platform)?.toLowerCase() ?? 'unknown',
    active: asBoolean(item.enabled) ?? false,
    deviceId: asString(item.deviceId) ?? undefined,
    appVersion: asString(item.appVersion) ?? undefined,
    timezone: asString(item.timezone) ?? undefined,
    provider: asString(item.provider)?.toLowerCase() ?? undefined,
    lastSeenAt: asString(item.lastSeenAt) ?? undefined,
    createdAt: asString(item.createdAt) ?? undefined,
  }));
}

// ---------------------------------------------------------------------------
// Companion transforms
// ---------------------------------------------------------------------------

export function mapCompanionInteractions(
  items: Array<Record<string, unknown>> | undefined,
) {
  if (!items?.length) {
    return undefined;
  }

  return items.slice(0, 3).map((item) => ({
    action: asString(item.type) ?? 'INTERACT',
    label: asString(item.type)?.replaceAll('_', ' ') ?? 'Interaction',
    at: formatClock(asString(item.createdAt)) ?? '--:--',
  }));
}

// ---------------------------------------------------------------------------
// Notifications & Weather transforms
// ---------------------------------------------------------------------------

export function mapNotifications(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => ({
    title: asString(item.title) ?? 'Notification',
    type: asString(item.type)?.toLowerCase() ?? 'notification',
    read: asBoolean(item.isRead) ?? false,
  }));
}

export function mapWeather(
  current?: Record<string, unknown>,
  forecast?: Array<Record<string, unknown>>,
) {
  if (!current) {
    return undefined;
  }

  const greeting = asRecord(current.greeting);
  const currentWeather = asRecord(current.current);

  return {
    greeting: {
      title: localWeatherGreeting(asNumber(currentWeather?.temperature)),
      subtitle: localWeatherSubtitle(asNumber(currentWeather?.temperature)),
      iconKey: asString(greeting?.iconKey) ?? 'weather-day',
    },
    current: {
      temperature: asNumber(currentWeather?.temperature) ?? 0,
      weatherCode: asNumber(currentWeather?.weatherCode) ?? 0,
      isDay: asBoolean(currentWeather?.isDay) ?? true,
    },
    forecast:
      forecast?.map((item) => ({
        day: formatForecastDay(asString(item.date)) ?? '--',
        temperature:
          asNumber(item.temperatureMax) ??
          asNumber(item.temperatureMin) ??
          0,
        rainChance: asNumber(item.precipitationProbability) ?? 0,
      })) ?? [],
  };
}

// ---------------------------------------------------------------------------
// Admin transforms
// ---------------------------------------------------------------------------

export function buildAdminMetrics(summaryCards?: Record<string, unknown>) {
  if (!summaryCards) {
    return undefined;
  }

  return [
    { label: 'DAU', value: formatCompact(asNumber(summaryCards.dau)), delta: ' ' },
    { label: 'WAU', value: formatCompact(asNumber(summaryCards.wau)), delta: ' ' },
    { label: 'MAU', value: formatCompact(asNumber(summaryCards.mau)), delta: ' ' },
    {
      label: 'MRR',
      value: formatCurrency(asNumber(summaryCards.mrr)),
      delta: formatDelta(asNumber(summaryCards.revenueDeltaPct)),
    },
    {
      label: 'Retention 7d',
      value: formatPercent(asNumber(summaryCards.retentionRate)),
      delta: `${asNumber(summaryCards.churnRiskUsers) ?? 0} risk`,
    },
    {
      label: 'Push delivered',
      value: formatPercent(asNumber(summaryCards.pushDeliveredRate)),
      delta: ' ',
    },
  ];
}

export function mapAdminTimeline(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => ({
    label: asString(item.label) ?? '--',
    users: asNumber(item.users) ?? 0,
    active: asNumber(item.active) ?? 0,
    revenue: asNumber(item.revenue) ?? 0,
  }));
}

export function mapAdminEngagement(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  const total = items.reduce((sum, item) => sum + (asNumber(item.count) ?? 0), 0);

  return items.map((item) => {
    const count = asNumber(item.count) ?? 0;
    return {
      name: toMoodLabel(asString(item.mood)) ?? 'Unknown',
      value: total > 0 ? Math.round((count / total) * 100) : 0,
    };
  });
}

export function mapAdminUsers(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => {
    const profile = asRecord(item.profile);
    const subscription = asRecord(
      asArray<Record<string, unknown>>(item.subscriptions)?.[0],
    );
    const tier = asRecord(subscription?.tier);
    const planName =
      asString(tier?.name) ?? asString(subscription?.planName) ?? 'FREE';
    const planStatus = asString(subscription?.status);

    return {
      id: asString(item.id) ?? crypto.randomUUID(),
      name:
        asString(profile?.displayName) ??
        asString(item.name) ??
        asString(item.email) ??
        'User',
      email: asString(item.email) ?? '-',
      role: asString(item.role) ?? 'USER',
      emailVerified: asBoolean(item.emailVerified) ?? false,
      status: asBoolean(item.isActive) ? 'ACTIVE' : 'INACTIVE',
      plan: planStatus ? `${planName} · ${planStatus}` : planName,
      streak: asNumber(profile?.currentStreak) ?? 0,
      lastLogin: formatDateTime(asString(item.lastLoginAt)) ?? '-',
    };
  });
}

export function mapAdminContent(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => ({
    area: asString(item.area) ?? 'Content',
    live: asNumber(item.live) ?? 0,
    drafts: asNumber(item.drafts) ?? 0,
    endpoint: asString(item.endpoint) ?? '-',
  }));
}

export function mapInfra(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => ({
    service: asString(item.service) ?? 'Service',
    status: asString(item.status) ?? 'UNKNOWN',
    latency: asString(item.latency) ?? '-',
  }));
}

// ---------------------------------------------------------------------------
// Helpers (private)
// ---------------------------------------------------------------------------

function getCurrentSessionId() {
  return getStoredSessionId() ?? getJwtSessionId(getStoredAccessToken());
}

function getJwtSessionId(token: string | undefined) {
  if (!token) {
    return undefined;
  }

  try {
    const [, payload] = token.split('.');
    if (!payload) {
      return undefined;
    }

    const normalizedPayload = payload
      .replace(/-/g, '+')
      .replace(/_/g, '/')
      .padEnd(Math.ceil(payload.length / 4) * 4, '=');
    const decoded = JSON.parse(atob(normalizedPayload)) as Record<string, unknown>;

    return asString(decoded.sessionId) ?? asString(decoded.sid);
  } catch {
    return undefined;
  }
}
