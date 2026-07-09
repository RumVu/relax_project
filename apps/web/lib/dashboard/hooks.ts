'use client';

import { useEffect, useMemo, useState } from 'react';
import { apiFetch } from '@/lib/api';
import { adminDashboardData, userDashboardData } from '@/lib/dashboard-data';
import { useTranslation } from '@/lib/i18n/i18n-provider';
import type { DashboardQuery, PageResponse } from './constants';
import { setActiveLocale } from './constants';
import { getSettledValue, pickQuery } from './coercions';
import { buildUserDashboardData, buildAdminDashboardData } from './builders';
import { createEmptyUserDashboardData, createEmptyAdminDashboardData } from './empty-state';

type UserDashboardData = typeof userDashboardData;
type AdminDashboardData = typeof adminDashboardData;

const EMPTY_USER_DASHBOARD_DATA = createEmptyUserDashboardData();
const EMPTY_ADMIN_DASHBOARD_DATA = createEmptyAdminDashboardData();

export type UserDashboardRequestOptions = {
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

export type AdminDashboardRequestOptions = {
  refreshKey?: number;
  overviewQuery?: DashboardQuery;
  usersQuery?: DashboardQuery;
};

export function useUserDashboardData(options: UserDashboardRequestOptions = {}) {
  const { locale } = useTranslation();
  const [data, setData] = useState<UserDashboardData>(EMPTY_USER_DASHBOARD_DATA);
  const requestKey = JSON.stringify({ ...options, locale });
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
        paymentsResult,
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
        apiFetch('/billing/me/payments'),
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
      const payments = getSettledValue<Array<Record<string, unknown>>>(paymentsResult);

      const nextData = buildUserDashboardData({
        locale,
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
        payments,
      });

      setData(nextData);
    }

    void load();

    return () => {
      cancelled = true;
    };
  }, [requestKey, stableOptions, locale]);

  return data;
}

export function useAdminDashboardData(options: AdminDashboardRequestOptions = {}) {
  const { locale } = useTranslation();
  const [data, setData] = useState<AdminDashboardData>(EMPTY_ADMIN_DASHBOARD_DATA);
  const requestKey = JSON.stringify({ ...options, locale });
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

      setActiveLocale(locale);
      setData(buildAdminDashboardData(EMPTY_ADMIN_DASHBOARD_DATA, overview, users));
    }

    void load();

    return () => {
      cancelled = true;
    };
  }, [requestKey, stableOptions, locale]);

  return data;
}
