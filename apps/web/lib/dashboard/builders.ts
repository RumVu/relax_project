import type { Locale } from '@/lib/i18n/dictionaries';
import type { PageResponse, UserDashboardData } from './constants';
import { setActiveLocale } from './constants';
import { adminDashboardData } from '@/lib/dashboard-data';
import {
  asArray,
  asBoolean,
  asNumber,
  asRecord,
  asString,
  normalizeCollection,
  readReliefPercent,
} from './coercions';
import {
  formatDate,
  formatDateTime,
  intensityToPercent,
  toMoodLabel,
} from './formatters';
import {
  buildDistribution,
  mapMoodOptions,
  mapTimeline,
  mapMoodHistory,
  mapWeeklyStats,
  mapRelaxActivities,
  mapFavoriteActivities,
  mapRecentMoments,
  mapJournalRecent,
  mapJournalMoodStats,
  mapRecommendations,
  mapSessions,
  mapReminderTimes,
  mapReminderTable,
  mapBilling,
  mapPayments,
  mapPushDevices,
  mapCompanionInteractions,
  mapNotifications,
  mapWeather,
  buildAdminMetrics,
  mapAdminTimeline,
  mapAdminEngagement,
  mapAdminUsers,
  mapAdminContent,
  mapInfra,
} from './transforms';

type AdminDashboardData = typeof adminDashboardData;

export function buildUserDashboardData(input: {
  locale?: Locale;
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
  payments?: Array<Record<string, unknown>>;
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
    payments,
  } = input;
  setActiveLocale(input.locale ?? 'vi');

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
          toMoodLabel(asString(currentMoodOption?.mood) ?? asString(currentMoodOption?.type)) ??
          toMoodLabel(asString(currentMoodCheckin?.mood)) ??
          toMoodLabel(asString(moodDashboardSummary?.topMood)) ??
          asString(currentMoodOption?.label) ??
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
      payments:
        mapPayments(payments) ?? base.settings.payments,
    },
  };
}

export function buildAdminDashboardData(
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
