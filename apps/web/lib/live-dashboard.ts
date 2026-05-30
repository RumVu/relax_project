'use client';

import { useEffect, useMemo, useState } from 'react';
import { apiFetch, getStoredAccessToken, getStoredSessionId } from '@/lib/api';
import { adminDashboardData, userDashboardData } from '@/lib/dashboard-data';

type UserDashboardData = typeof userDashboardData;
type AdminDashboardData = typeof adminDashboardData;
type DashboardQuery = Record<string, string | number | boolean | undefined>;

type PageResponse<T> = {
  items?: T[];
  total?: number;
};

type MoodOption = (typeof userDashboardData.moodOptions)[number];

const moodOptionByType = new Map<string, MoodOption>(
  userDashboardData.moodOptions.map((option) => [option.type, option]),
);

const moodLabelByType = new Map<string, string>(
  userDashboardData.moodOptions.map((option) => [option.type, option.label]),
);

const EMPTY_USER_DASHBOARD_DATA = createEmptyUserDashboardData();
const EMPTY_ADMIN_DASHBOARD_DATA = createEmptyAdminDashboardData();

type UserDashboardRequestOptions = {
  refreshKey?: number;
  overviewQuery?: DashboardQuery;
  moodQuery?: DashboardQuery;
  moodAnalyticsQuery?: DashboardQuery;
  weeklyStatsQuery?: DashboardQuery;
  journalQuery?: DashboardQuery;
  relaxQuery?: DashboardQuery;
  reminderQuery?: DashboardQuery;
  notificationQuery?: DashboardQuery;
};

type AdminDashboardRequestOptions = {
  refreshKey?: number;
  overviewQuery?: DashboardQuery;
  usersQuery?: DashboardQuery;
};

export function useUserDashboardData(options: UserDashboardRequestOptions = {}) {
  const [data, setData] = useState<UserDashboardData>(EMPTY_USER_DASHBOARD_DATA);
  const requestKey = JSON.stringify(options);
  const stableOptions = useMemo(
    () => JSON.parse(requestKey) as UserDashboardRequestOptions,
    [requestKey],
  );

  useEffect(() => {
    let cancelled = false;
    const moodListQuery = pickQuery(stableOptions.moodQuery, [
      'mood',
      'from',
      'to',
      'skip',
      'limit',
    ]);
    const moodAnalyticsQuery = pickQuery(stableOptions.moodAnalyticsQuery, [
      'period',
      'from',
      'to',
      'compare',
      'timezone',
      'timezoneOffsetMinutes',
    ]);
    const weeklyStatsQuery = pickQuery(stableOptions.weeklyStatsQuery, [
      'mood',
      'from',
      'to',
      'skip',
      'limit',
    ]);
    const weatherQuery = pickQuery(stableOptions.overviewQuery, [
      'latitude',
      'longitude',
      'timezone',
    ]);
    const relaxQuery = pickQuery(stableOptions.relaxQuery, [
      'activityType',
      'period',
      'from',
      'to',
      'skip',
      'limit',
      'timezone',
      'timezoneOffsetMinutes',
    ]);

    async function load() {
      const [
        overviewResult,
        moodOptionsResult,
        moodListResult,
        moodStatsResult,
        moodDashboardResult,
        moodAnalyticsResult,
        weeklyStatsResult,
        journalsResult,
        journalStatsResult,
        preferencesResult,
        sessionsResult,
        remindersResult,
        billingResult,
        authMeResult,
        profileResult,
        weatherCurrentResult,
        weatherForecastResult,
        notificationsResult,
        unreadCountResult,
        pushDevicesResult,
        relaxActivitiesResult,
        relaxStatsResult,
        relaxSessionsResult,
      ] = await Promise.allSettled([
        apiFetch('/analytics/me/overview', undefined, {
          query: stableOptions.overviewQuery,
        }),
        apiFetch('/mood-checkins/options'),
        apiFetch('/mood-checkins/me', undefined, {
          query: moodListQuery,
        }),
        apiFetch('/mood-checkins/me/stats', undefined, {
          query: moodListQuery,
        }),
        apiFetch('/mood-checkins/me/dashboard', undefined, {
          query: moodListQuery,
        }),
        apiFetch('/mood-checkins/me/analytics', undefined, {
          query: moodAnalyticsQuery,
        }),
        apiFetch('/mood-checkins/me/weekly-stats', undefined, {
          query: weeklyStatsQuery,
        }),
        apiFetch('/journals/me', undefined, {
          query: stableOptions.journalQuery,
        }),
        apiFetch('/journals/me/stats', undefined, {
          query: stableOptions.journalQuery,
        }),
        apiFetch('/user-preferences/me/preferences'),
        apiFetch('/sessions/me'),
        apiFetch('/reminders/me', undefined, {
          query: { limit: 10, ...stableOptions.reminderQuery },
        }),
        apiFetch('/billing/me'),
        apiFetch('/auth/me'),
        apiFetch('/user-profiles/me/profile'),
        apiFetch('/weather/me/current', undefined, {
          query: weatherQuery,
        }),
        apiFetch('/weather/me/forecast', undefined, {
          query: {
            forecastDays: 7,
            ...weatherQuery,
          },
        }),
        apiFetch('/notifications/me', undefined, {
          query: {
            limit: 5,
            ...(stableOptions.notificationQuery ?? {}),
          },
        }),
        apiFetch('/notifications/me/unread-count'),
        apiFetch('/notifications/me/devices'),
        apiFetch('/relax-activities'),
        apiFetch('/relax-activities/me/stats', undefined, {
          query: relaxQuery,
        }),
        apiFetch('/relax-activities/me/sessions', undefined, {
          query: relaxQuery,
        }),
      ]);

      if (cancelled) {
        return;
      }

      const overview = getSettledValue<Record<string, unknown>>(overviewResult);
      const moodOptionsResponse = getSettledValue<Array<Record<string, unknown>> | PageResponse<Record<string, unknown>>>(moodOptionsResult);
      const moodList = getSettledValue<PageResponse<Record<string, unknown>>>(moodListResult);
      const moodStats = getSettledValue<Record<string, unknown>>(moodStatsResult);
      const moodDashboard = getSettledValue<Record<string, unknown>>(moodDashboardResult);
      const moodAnalytics = getSettledValue<Record<string, unknown>>(moodAnalyticsResult);
      const weeklyStats = getSettledValue<Array<Record<string, unknown>>>(weeklyStatsResult);
      const journals = getSettledValue<PageResponse<Record<string, unknown>>>(journalsResult);
      const journalStats = getSettledValue<Record<string, unknown>>(journalStatsResult);
      const preferences = getSettledValue<Record<string, unknown>>(preferencesResult);
      const sessions = getSettledValue<Array<Record<string, unknown>>>(sessionsResult);
      const reminders = getSettledValue<PageResponse<Record<string, unknown>>>(remindersResult);
      const billing = getSettledValue<Record<string, unknown>>(billingResult);
      const authMe = getSettledValue<Record<string, unknown>>(authMeResult);
      const profile = getSettledValue<Record<string, unknown>>(profileResult);
      const weatherCurrent = getSettledValue<Record<string, unknown>>(weatherCurrentResult);
      const weatherForecast = getSettledValue<Record<string, unknown>>(weatherForecastResult);
      const notifications = getSettledValue<PageResponse<Record<string, unknown>>>(notificationsResult);
      const unreadCount = getSettledValue<Record<string, unknown>>(unreadCountResult);
      const pushDevices = getSettledValue<Array<Record<string, unknown>>>(pushDevicesResult);
      const relaxActivities = getSettledValue<Array<Record<string, unknown>> | PageResponse<Record<string, unknown>>>(relaxActivitiesResult);
      const relaxStats = getSettledValue<Record<string, unknown>>(relaxStatsResult);
      const relaxSessions = getSettledValue<PageResponse<Record<string, unknown>> | Array<Record<string, unknown>>>(relaxSessionsResult);

      const nextData = buildUserDashboardData({
        base: EMPTY_USER_DASHBOARD_DATA,
        overview,
        moodOptionsResponse,
        moodList,
        moodStats,
        moodDashboard,
        moodAnalytics,
        weeklyStats,
        journals,
        journalStats,
        preferences,
        sessions,
        reminders,
        billing,
        authMe,
        profile,
        weatherCurrent,
        weatherForecast,
        notifications,
        unreadCount,
        pushDevices,
        relaxActivities,
        relaxStats,
        relaxSessions,
      });

      setData(nextData);
    }

    void load();

    return () => {
      cancelled = true;
    };
  }, [requestKey, stableOptions]);

  return data;
}

export function useAdminDashboardData(options: AdminDashboardRequestOptions = {}) {
  const [data, setData] = useState<AdminDashboardData>(EMPTY_ADMIN_DASHBOARD_DATA);
  const requestKey = JSON.stringify(options);
  const stableOptions = useMemo(
    () => JSON.parse(requestKey) as AdminDashboardRequestOptions,
    [requestKey],
  );

  useEffect(() => {
    let cancelled = false;

    async function load() {
      const [overviewResult, usersResult] = await Promise.allSettled([
        apiFetch('/admin/analytics/overview', undefined, {
          query: stableOptions.overviewQuery,
        }),
        apiFetch('/users', undefined, {
          query: { limit: 12, ...(stableOptions.usersQuery ?? {}) },
        }),
      ]);

      if (cancelled) {
        return;
      }

      const overview = getSettledValue<Record<string, unknown>>(overviewResult);
      const users = getSettledValue<PageResponse<Record<string, unknown>>>(usersResult);

      setData(buildAdminDashboardData(EMPTY_ADMIN_DASHBOARD_DATA, overview, users));
    }

    void load();

    return () => {
      cancelled = true;
    };
  }, [requestKey, stableOptions]);

  return data;
}

function buildUserDashboardData(input: {
  base: UserDashboardData;
  overview?: Record<string, unknown>;
  moodOptionsResponse?: Array<Record<string, unknown>> | PageResponse<Record<string, unknown>>;
  moodList?: PageResponse<Record<string, unknown>>;
  moodStats?: Record<string, unknown>;
  moodDashboard?: Record<string, unknown>;
  moodAnalytics?: Record<string, unknown>;
  weeklyStats?: Array<Record<string, unknown>>;
  journals?: PageResponse<Record<string, unknown>>;
  journalStats?: Record<string, unknown>;
  preferences?: Record<string, unknown>;
  sessions?: Array<Record<string, unknown>>;
  reminders?: PageResponse<Record<string, unknown>>;
  billing?: Record<string, unknown>;
  authMe?: Record<string, unknown>;
  profile?: Record<string, unknown>;
  weatherCurrent?: Record<string, unknown>;
  weatherForecast?: Record<string, unknown>;
  notifications?: PageResponse<Record<string, unknown>>;
  unreadCount?: Record<string, unknown>;
  pushDevices?: Array<Record<string, unknown>>;
  relaxActivities?: Array<Record<string, unknown>> | PageResponse<Record<string, unknown>>;
  relaxStats?: Record<string, unknown>;
  relaxSessions?: PageResponse<Record<string, unknown>> | Array<Record<string, unknown>>;
}) {
  const {
    base,
    overview,
    moodOptionsResponse,
    moodList,
    moodStats,
    moodDashboard,
    moodAnalytics,
    weeklyStats,
    journals,
    journalStats,
    preferences,
    sessions,
    reminders,
    billing,
    authMe,
    profile,
    weatherCurrent,
    weatherForecast,
    notifications,
    unreadCount,
    pushDevices,
    relaxActivities,
    relaxStats,
    relaxSessions,
  } = input;

  const moodAnalyticsSummary = asRecord(moodAnalytics?.summary);
  const moodAnalyticsDelta = asRecord(moodAnalytics?.delta);
  const moodDashboardSummary = asRecord(moodDashboard?.summary);
  const currentMood = asRecord(moodDashboard?.currentMood);
  const currentMoodOption = asRecord(currentMood?.option);
  const currentMoodCheckin = asRecord(currentMood?.checkin);
  const overviewMood = asRecord(overview?.mood);
  const overviewJournals = asRecord(overview?.journals);
  const overviewRelax = asRecord(overview?.relax);
  const overviewCompanion = asRecord(overview?.companion);
  const summaryCards = asRecord(overview?.summaryCards);
  const reminderItems = reminders?.items ?? [];
  const sessionItems = sessions ?? [];
  const journalRecent = asArray<Record<string, unknown>>(journalStats?.recent);
  const journalByMood = asArray<Record<string, unknown>>(journalStats?.byMood);
  const moodDistribution =
    buildDistribution(
      asArray<Record<string, unknown>>(moodAnalytics?.distribution),
      asNumber(moodAnalyticsSummary?.total) ??
        asNumber(moodDashboardSummary?.total) ??
        undefined,
    ) ??
    buildDistribution(
      asArray<Record<string, unknown>>(moodDashboard?.distribution),
      asNumber(moodDashboardSummary?.total) ?? undefined,
    ) ??
    base.distribution;
  const relaxFavoriteActivities = asArray<Record<string, unknown>>(
    relaxStats?.favoriteActivities ?? overviewRelax?.favoriteActivities,
  );
  const relaxRecentMoments = asArray<Record<string, unknown>>(
    relaxStats?.recentMoments ?? overviewRelax?.recentMoments,
  );
  const notificationItems = notifications?.items ?? [];
  const profileRecord = asRecord(profile);
  const weatherCurrentRecord = asRecord(weatherCurrent);
  const weatherForecastList = asArray<Record<string, unknown>>(weatherForecast?.forecast);
  const authProfile = asRecord(authMe?.profile);
  const authPreferences = asRecord(authMe?.preferences);
  const relaxPayload = relaxStats ?? overviewRelax;
  const moodOptionItems = normalizeCollection(moodOptionsResponse);
  const relaxCatalogItems = normalizeCollection(relaxActivities);
  const relaxSessionItems = normalizeCollection(relaxSessions);

  return {
    ...base,
    overview: {
      ...base.overview,
      period: asString(overview?.period) ?? base.overview.period,
      timezone: asString(overview?.timezone) ?? base.overview.timezone,
      summaryCards: {
        currentStreak:
          asNumber(summaryCards?.currentStreak) ??
          asNumber(moodDashboardSummary?.currentStreak) ??
          base.overview.summaryCards.currentStreak,
        totalRelaxTime:
          asString(summaryCards?.totalRelaxTime) ??
          asString(relaxPayload?.totalDurationLabel) ??
          base.overview.summaryCards.totalRelaxTime,
        totalJournals:
          asNumber(summaryCards?.totalJournals) ??
          asNumber(journalStats?.total) ??
          base.overview.summaryCards.totalJournals,
        companionAffection:
          asNumber(summaryCards?.companionAffection) ??
          asNumber(asRecord(overviewCompanion?.companion)?.affection) ??
          base.overview.summaryCards.companionAffection,
        stressReduction:
          asNumber(summaryCards?.stressReduction) ??
          asNumber(moodAnalyticsDelta?.stressReduction) ??
          base.overview.summaryCards.stressReduction,
      },
      mood: {
        currentMood:
          asString(currentMoodOption?.label) ??
          toMoodLabel(asString(currentMoodCheckin?.mood)) ??
          toMoodLabel(asString(moodDashboardSummary?.topMood)) ??
          base.overview.mood.currentMood,
        prompt:
          asString(asRecord(moodDashboard?.companion)?.prompt) ??
          asString(overviewMood?.prompt) ??
          base.overview.mood.prompt,
        summary: {
          total:
            asNumber(moodDashboardSummary?.total) ??
            asNumber(moodAnalyticsSummary?.total) ??
            base.overview.mood.summary.total,
          topMood:
            toMoodLabel(asString(moodDashboardSummary?.topMood)) ??
            toMoodLabel(asString(moodAnalyticsSummary?.topMood)) ??
            base.overview.mood.summary.topMood,
          currentStreak:
            asNumber(moodDashboardSummary?.currentStreak) ??
            base.overview.mood.summary.currentStreak,
          longestStreak:
            asNumber(moodDashboardSummary?.longestStreak) ??
            base.overview.mood.summary.longestStreak,
          averageIntensity:
            intensityToPercent(asNumber(moodStats?.averageIntensity)) ??
            intensityToPercent(asNumber(moodAnalyticsSummary?.averageIntensity)) ??
            base.overview.mood.summary.averageIntensity,
        },
        recommendations:
          mapRecommendations(asArray<unknown>(moodDashboard?.recommendations)) ??
          base.overview.mood.recommendations,
      },
      journals: {
        total: asNumber(journalStats?.total) ?? base.overview.journals.total,
        favorites:
          asNumber(journalStats?.favorites) ?? base.overview.journals.favorites,
        recent:
          mapJournalRecent(journalRecent) ?? base.overview.journals.recent,
        byMood: mapJournalMoodStats(journalByMood) ?? base.overview.journals.byMood,
      },
      relax: {
        totalSessions:
          asNumber(relaxPayload?.totalSessions) ??
          base.overview.relax.totalSessions,
        totalDurationSeconds:
          asNumber(relaxPayload?.totalDurationSeconds) ??
          base.overview.relax.totalDurationSeconds,
        totalDurationLabel:
          asString(relaxPayload?.totalDurationLabel) ??
          base.overview.relax.totalDurationLabel,
        streak:
          asNumber(asRecord(relaxPayload?.streak)?.current) ??
          asNumber(relaxPayload?.streak) ??
          base.overview.relax.streak,
        relief:
          readReliefPercent(asRecord(relaxPayload?.relief)) ??
          readReliefPercent(relaxPayload) ??
          base.overview.relax.relief,
        favoriteActivities:
          mapFavoriteActivities(relaxFavoriteActivities) ??
          base.overview.relax.favoriteActivities,
        recentMoments:
          mapRecentMoments(relaxSessionItems) ??
          mapRecentMoments(relaxRecentMoments) ??
          base.overview.relax.recentMoments,
      },
      companion: {
        level:
          asNumber(asRecord(overviewCompanion?.companion)?.level) ??
          base.overview.companion.level,
        affection:
          asNumber(asRecord(overviewCompanion?.companion)?.affection) ??
          base.overview.companion.affection,
        energy:
          asNumber(asRecord(overviewCompanion?.companion)?.energy) ??
          base.overview.companion.energy,
        mood:
          asString(asRecord(overviewCompanion?.companion)?.mood)?.toLowerCase() ??
          base.overview.companion.mood,
        action:
          asString(asRecord(overviewCompanion?.companion)?.action)?.toLowerCase() ??
          base.overview.companion.action,
        lastFedAt:
          formatDateTime(asString(asRecord(overviewCompanion?.companion)?.lastFedAt)) ??
          base.overview.companion.lastFedAt,
        totalInteractions:
          asNumber(overviewCompanion?.totalInteractions) ??
          base.overview.companion.totalInteractions,
        recentInteractions:
          mapCompanionInteractions(
            asArray<Record<string, unknown>>(overviewCompanion?.recentInteractions),
          ) ?? base.overview.companion.recentInteractions,
      },
      notifications: {
        unreadCount:
          asNumber(unreadCount?.count) ?? base.overview.notifications.unreadCount,
        list:
          mapNotifications(notificationItems) ?? base.overview.notifications.list,
      },
      weather:
        mapWeather(weatherCurrentRecord, weatherForecastList) ?? base.overview.weather,
    },
    moodOptions:
      mapMoodOptions(moodOptionItems) ??
      mapMoodOptions(asArray<Record<string, unknown>>(moodDashboard?.options)) ??
      base.moodOptions,
    moodHistory:
      mapMoodHistory(moodList?.items) ?? base.moodHistory,
    timeline:
      mapTimeline(asArray<Record<string, unknown>>(moodAnalytics?.timeline)) ??
      base.timeline,
    distribution: moodDistribution,
    weeklyStats: mapWeeklyStats(weeklyStats) ?? base.weeklyStats,
    relaxActivities:
      mapRelaxActivities(relaxCatalogItems, relaxFavoriteActivities) ??
      base.relaxActivities,
    settings: {
      profile: {
        ...base.settings.profile,
        displayName:
          asString(profileRecord?.displayName) ??
          asString(authProfile?.displayName) ??
          asString(authMe?.name) ??
          base.settings.profile.displayName,
        email: asString(authMe?.email) ?? base.settings.profile.email,
        avatar:
          asString(authMe?.avatar) ?? base.settings.profile.avatar ?? null,
        birthday:
          formatDate(asString(profileRecord?.birthday)) ??
          base.settings.profile.birthday,
        zodiacSign:
          asString(profileRecord?.zodiacSign) ?? base.settings.profile.zodiacSign,
        chineseZodiac:
          asString(profileRecord?.chineseZodiac) ??
          base.settings.profile.chineseZodiac,
      } as UserDashboardData['settings']['profile'],
      preferences: {
        ...base.settings.preferences,
        theme:
          asString(preferences?.themeMode)?.toLowerCase() ??
          asString(authPreferences?.themeMode)?.toLowerCase() ??
          base.settings.preferences.theme,
        timezone:
          asString(preferences?.timezone) ??
          asString(authPreferences?.timezone) ??
          base.settings.preferences.timezone,
        weatherEnabled:
          asBoolean(preferences?.weatherEnabled) ??
          asBoolean(authPreferences?.weatherEnabled) ??
          base.settings.preferences.weatherEnabled,
        locationName:
          asString(preferences?.locationName) ??
          asString(asRecord(weatherCurrentRecord?.location)?.name) ??
          base.settings.preferences.locationName,
        reminderTimes:
          mapReminderTimes(reminderItems) ?? base.settings.preferences.reminderTimes,
        soundEnabled:
          asBoolean(preferences?.enableSound) ??
          asBoolean(authPreferences?.enableSound) ??
          base.settings.preferences.soundEnabled,
        pushEnabled:
          asBoolean(preferences?.pushNotificationsEnabled) ??
          asBoolean(authPreferences?.pushNotificationsEnabled) ??
          base.settings.preferences.pushEnabled,
        emailEnabled:
          asBoolean(preferences?.emailNotificationsEnabled) ??
          asBoolean(authPreferences?.emailNotificationsEnabled) ??
          base.settings.preferences.emailEnabled,
      },
      sessions:
        mapSessions(sessionItems) ?? base.settings.sessions,
      pushDevices: mapPushDevices(pushDevices) ?? base.settings.pushDevices,
      reminders:
        mapReminderTable(reminderItems) ?? base.settings.reminders,
      billing:
        mapBilling(asRecord(billing?.subscription)) ?? base.settings.billing,
    },
  };
}

function buildAdminDashboardData(
  base: AdminDashboardData,
  overview?: Record<string, unknown>,
  usersPage?: PageResponse<Record<string, unknown>>,
) {
  const summaryCards = asRecord(overview?.summaryCards);
  const timeline = asArray<Record<string, unknown>>(overview?.timeline);
  const moodDistribution = asArray<Record<string, unknown>>(
    asRecord(overview?.engagement)?.moodDistribution,
  );
  const operations = asArray<Record<string, unknown>>(overview?.operations);
  const content = asArray<Record<string, unknown>>(overview?.content);
  const users = usersPage?.items ?? [];

  return {
    ...base,
    metrics:
      buildAdminMetrics(summaryCards) ?? base.metrics,
    userGrowth: mapAdminTimeline(timeline) ?? base.userGrowth,
    contentEngagement:
      mapAdminEngagement(moodDistribution) ?? base.contentEngagement,
    users: mapAdminUsers(users) ?? base.users,
    infra: mapInfra(operations) ?? base.infra,
    content: mapAdminContent(content) ?? base.content,
  };
}

function buildDistribution(
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
        asString(item.label) ??
        toMoodLabel(asString(item.mood)) ??
        'Unknown',
      count,
      percent:
        asNumber(item.percent) ??
        (resolvedTotal > 0 ? Math.round((count / resolvedTotal) * 100) : 0),
    };
  });
}

function mapMoodOptions(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => {
    const type = asString(item.mood);
    const fallback = type ? moodOptionByType.get(type) : undefined;

    return {
      type: type ?? fallback?.type ?? 'NEUTRAL',
      label:
        asString(item.label) ??
        fallback?.label ??
        toMoodLabel(type) ??
        'Bình thường',
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

function mapTimeline(items: Array<Record<string, unknown>> | undefined) {
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

function mapMoodHistory(items: Array<Record<string, unknown>> | undefined) {
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
      'Không có ghi chú',
    intensity: asNumber(item.intensity) ?? 0,
  }));
}

function mapWeeklyStats(items: Array<Record<string, unknown>> | undefined) {
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

function mapRelaxActivities(
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
        'Hoạt động thư giãn',
      duration:
        formatDurationFromMinutes(
          asNumber(item.defaultDurationMinutes) ?? asNumber(item.durationMinutes),
        ) ??
        asString(item.durationLabel) ??
        formatDurationFromSeconds(asNumber(item.durationSeconds)) ??
        '0 phút',
      sessions: asNumber(matched?.count) ?? 0,
      relief: readReliefPercent(matched) ?? readReliefPercent(item) ?? 0,
    };
  });
}

function mapFavoriteActivities(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => ({
    activityType: asString(item.type) ?? 'MUSIC',
    label: asString(item.title) ?? 'Hoạt động',
    totalDurationSeconds: asNumber(item.durationSeconds) ?? 0,
    sessions: asNumber(item.count) ?? 0,
  }));
}

function mapRecentMoments(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => ({
    title: asString(item.title) ?? 'Session',
    time: formatClock(asString(item.endedAt) ?? asString(item.startedAt)) ?? '--:--',
    duration:
      formatDurationFromSeconds(asNumber(item.durationSeconds)) ?? '0 phút',
    relief: readReliefPercent(item) ?? 0,
  }));
}

function mapJournalRecent(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => ({
    id: asString(item.id) ?? crypto.randomUUID(),
    title: asString(item.title) ?? 'Nhật ký',
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

function mapJournalMoodStats(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => ({
    mood: toMoodLabel(asString(item.mood)) ?? 'Unknown',
    count: asNumber(item.count) ?? 0,
  }));
}

function mapRecommendations(items: unknown[] | undefined) {
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

function mapSessions(items: Array<Record<string, unknown>> | undefined) {
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

function formatIpAddress(ipAddress?: string) {
  const value = ipAddress?.trim();

  if (!value) {
    return 'Chưa ghi nhận';
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

function mapReminderTimes(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items
    .map((item) => formatClock(asString(item.scheduledAt)))
    .filter((item): item is string => Boolean(item));
}

function mapReminderTable(items: Array<Record<string, unknown>> | undefined) {
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

function mapBilling(subscription?: Record<string, unknown>) {
  if (!subscription) {
    return {
      planName: 'Chưa có gói',
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

function mapCompanionInteractions(
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

function mapNotifications(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => ({
    title: asString(item.title) ?? 'Notification',
    type: asString(item.type)?.toLowerCase() ?? 'notification',
    read: asBoolean(item.isRead) ?? false,
  }));
}

function mapPushDevices(items: Array<Record<string, unknown>> | undefined) {
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
  }));
}

function mapWeather(
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
      title: asString(greeting?.title) ?? 'Hello',
      subtitle: asString(greeting?.subtitle) ?? '',
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

function buildAdminMetrics(summaryCards?: Record<string, unknown>) {
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

function mapAdminTimeline(items: Array<Record<string, unknown>> | undefined) {
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

function mapAdminEngagement(items: Array<Record<string, unknown>> | undefined) {
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

function mapAdminUsers(items: Array<Record<string, unknown>> | undefined) {
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

function mapAdminContent(items: Array<Record<string, unknown>> | undefined) {
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

function mapInfra(items: Array<Record<string, unknown>> | undefined) {
  if (!items?.length) {
    return undefined;
  }

  return items.map((item) => ({
    service: asString(item.service) ?? 'Service',
    status: asString(item.status) ?? 'UNKNOWN',
    latency: asString(item.latency) ?? '-',
  }));
}

function getSettledValue<T>(result: PromiseSettledResult<unknown>) {
  return result.status === 'fulfilled' ? (result.value as T) : undefined;
}

function pickQuery(
  query: DashboardQuery | undefined,
  keys: string[],
): DashboardQuery | undefined {
  if (!query) {
    return undefined;
  }

  const picked = Object.fromEntries(
    keys
      .filter((key) => {
        const value = query[key];
        return value !== undefined && value !== '';
      })
      .map((key) => [key, query[key]]),
  ) as DashboardQuery;

  return Object.keys(picked).length > 0 ? picked : undefined;
}

function asRecord(value: unknown) {
  return value && typeof value === 'object' && !Array.isArray(value)
    ? (value as Record<string, unknown>)
    : undefined;
}

function asArray<T>(value: unknown) {
  return Array.isArray(value) ? (value as T[]) : undefined;
}

function asString(value: unknown) {
  return typeof value === 'string' && value.trim().length > 0 ? value : undefined;
}

function asNumber(value: unknown) {
  return typeof value === 'number' && Number.isFinite(value) ? value : undefined;
}

function readReliefPercent(record: Record<string, unknown> | undefined) {
  if (!record) {
    return undefined;
  }

  const nestedRelief = asRecord(record.relief);
  const value =
    asNumber(record.stressReliefPercent) ??
    asNumber(record.reliefPercent) ??
    asNumber(record.reliefPct) ??
    asNumber(record.relief) ??
    asNumber(record.averageStressRelief) ??
    asNumber(record.avgStressRelief) ??
    asNumber(record.averageRelief) ??
    asNumber(record.avgRelief) ??
    asNumber(nestedRelief?.averageStressRelief) ??
    asNumber(nestedRelief?.stressReliefPercent) ??
    asNumber(nestedRelief?.percent);

  if (value === undefined) {
    return undefined;
  }

  return Math.max(0, Math.min(100, Math.round(value)));
}

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

function asBoolean(value: unknown) {
  return typeof value === 'boolean' ? value : undefined;
}

function asStringArray(value: unknown) {
  return Array.isArray(value)
    ? value.filter((item): item is string => typeof item === 'string')
    : [];
}

function truncate(value: string | undefined, maxLength: number) {
  if (!value) {
    return undefined;
  }

  return value.length > maxLength ? `${value.slice(0, maxLength - 1)}…` : value;
}

function toMoodLabel(mood: string | undefined) {
  if (!mood) {
    return undefined;
  }

  return moodLabelByType.get(mood) ?? titleize(mood);
}

function intensityToPercent(value: number | undefined) {
  if (value === undefined) {
    return undefined;
  }

  return Math.max(0, Math.min(100, Math.round(value * 20)));
}

function formatDateTime(value: string | undefined) {
  if (!value) {
    return undefined;
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return undefined;
  }

  return date.toLocaleString('vi-VN', {
    day: '2-digit',
    month: '2-digit',
    year: 'numeric',
    hour: '2-digit',
    minute: '2-digit',
  });
}

function formatDate(value: string | undefined) {
  if (!value) {
    return undefined;
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return undefined;
  }

  return date.toLocaleDateString('vi-VN');
}

function formatClock(value: string | undefined) {
  if (!value) {
    return undefined;
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return undefined;
  }

  return date.toLocaleTimeString('vi-VN', {
    hour: '2-digit',
    minute: '2-digit',
  });
}

function formatDurationFromSeconds(value: number | undefined) {
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

  return `${minutes} phút`;
}

function formatDurationFromMinutes(value: number | undefined) {
  if (value === undefined) {
    return undefined;
  }

  if (value >= 60) {
    const hours = Math.floor(value / 60);
    const remainingMinutes = value % 60;
    return remainingMinutes > 0 ? `${hours}h ${remainingMinutes}m` : `${hours}h`;
  }

  return `${Math.max(1, Math.round(value))} phút`;
}

function formatReminderSchedule(item: Record<string, unknown>) {
  const scheduledAt = formatDateTime(asString(item.scheduledAt));
  const repeatRule = asString(item.repeatRule);
  return repeatRule ? `${scheduledAt ?? '--'} • ${repeatRule}` : scheduledAt ?? '--';
}

function formatCompact(value: number | undefined) {
  if (value === undefined) {
    return '-';
  }

  return new Intl.NumberFormat('vi-VN', {
    notation: 'compact',
    maximumFractionDigits: 1,
  }).format(value);
}

function formatCurrency(value: number | undefined) {
  if (value === undefined) {
    return '-';
  }

  return new Intl.NumberFormat('vi-VN', {
    style: 'currency',
    currency: 'VND',
    maximumFractionDigits: 0,
  }).format(value);
}

function formatPercent(value: number | undefined) {
  if (value === undefined) {
    return '-';
  }

  return `${Math.round(value)}%`;
}

function formatDelta(value: number | undefined) {
  if (value === undefined) {
    return '—';
  }

  const rounded = Math.round(value * 10) / 10;
  return `${rounded > 0 ? '+' : ''}${rounded}%`;
}

function titleize(value: string) {
  return value
    .toLowerCase()
    .split('_')
    .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
    .join(' ');
}

function normalizeCollection(
  value:
    | Array<Record<string, unknown>>
    | PageResponse<Record<string, unknown>>
    | undefined,
) {
  if (Array.isArray(value)) {
    return value;
  }

  return value?.items;
}

function formatForecastDay(value: string | undefined) {
  if (!value) {
    return undefined;
  }

  const date = new Date(value);
  if (Number.isNaN(date.getTime())) {
    return undefined;
  }

  return date.toLocaleDateString('vi-VN', { weekday: 'short' });
}

function createEmptyUserDashboardData(): UserDashboardData {
  return {
    overview: {
      period: '',
      timezone: '',
      summaryCards: {
        currentStreak: 0,
        totalRelaxTime: '0 phút',
        totalJournals: 0,
        companionAffection: 0,
        stressReduction: 0,
      },
      mood: {
        currentMood: 'Chưa có dữ liệu',
        prompt: 'Kết nối tài khoản rồi bắt đầu check-in để hệ thống hiểu tâm trạng của anh.',
        summary: {
          total: 0,
          topMood: 'Chưa có dữ liệu',
          currentStreak: 0,
          longestStreak: 0,
          averageIntensity: 0,
        },
        recommendations: [],
      },
      journals: {
        total: 0,
        favorites: 0,
        recent: [],
        byMood: [],
      },
      relax: {
        totalSessions: 0,
        totalDurationSeconds: 0,
        totalDurationLabel: '0 phút',
        streak: 0,
        relief: 0,
        favoriteActivities: [],
        recentMoments: [],
      },
      companion: {
        level: 0,
        affection: 0,
        energy: 0,
        mood: 'idle',
        action: 'idle',
        lastFedAt: '',
        totalInteractions: 0,
        recentInteractions: [],
      },
      weather: {
        greeting: {
          title: 'Chưa có dữ liệu thời tiết',
          subtitle: '',
          iconKey: 'weather-day',
        },
        current: {
          temperature: 0,
          weatherCode: 0,
          isDay: true,
        },
        forecast: [],
      },
      notifications: {
        unreadCount: 0,
        list: [],
      },
    },
    moodOptions: userDashboardData.moodOptions,
    moodHistory: [],
    timeline: [],
    distribution: [],
    weeklyStats: [],
    relaxActivities: [],
    settings: {
      profile: {
        displayName: '',
        email: '',
        avatar: null,
        birthday: '',
        zodiacSign: '',
        chineseZodiac: '',
      },
      preferences: {
        theme: 'system',
        timezone: 'Asia/Ho_Chi_Minh',
        weatherEnabled: false,
        locationName: '',
        reminderTimes: [],
        soundEnabled: false,
        pushEnabled: false,
        emailEnabled: false,
      },
      sessions: [],
      pushDevices: [],
      reminders: [],
      billing: {
        planName: 'Chưa có gói',
        status: 'inactive',
        renewal: '—',
      },
    },
  };
}

function createEmptyAdminDashboardData(): AdminDashboardData {
  return {
    metrics: [],
    userGrowth: [],
    contentEngagement: [],
    users: [],
    infra: [],
    content: [],
  };
}
