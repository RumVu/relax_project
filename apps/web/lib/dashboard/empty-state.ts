import { userDashboardData, adminDashboardData } from '@/lib/dashboard-data';
import { activeLocale, moodLabelByType, moodLabelEnByType } from './constants';

type UserDashboardData = typeof userDashboardData;
type AdminDashboardData = typeof adminDashboardData;

export function createEmptyUserDashboardData(): UserDashboardData {
  // Co y doc `activeLocale` o thoi diem goi de initial-render hien thi
  // dung ngon ngu user dang chon, thay vi luon Vi roi moi replace.
  const isVi = activeLocale === 'vi';
  const noData = isVi ? 'Chưa có dữ liệu' : 'No data yet';
  const minutesUnit = isVi ? '0 phút' : '0 min';
  return {
    overview: {
      period: '',
      timezone: '',
      summaryCards: {
        currentStreak: 0,
        totalRelaxTime: minutesUnit,
        totalJournals: 0,
        companionAffection: 0,
        stressReduction: 0,
      },
      mood: {
        currentMood: noData,
        prompt: isVi
          ? 'Kết nối tài khoản rồi bắt đầu check-in để hệ thống hiểu tâm trạng của anh.'
          : 'Sign in and start checking in so we can learn your mood pattern.',
        summary: {
          total: 0,
          topMood: noData,
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
        totalDurationLabel: minutesUnit,
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
          title: isVi ? 'Chưa có dữ liệu thời tiết' : 'No weather data yet',
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
    moodOptions: userDashboardData.moodOptions.map((option) => ({
      ...option,
      label:
        (isVi ? moodLabelByType : moodLabelEnByType).get(option.type) ??
        option.label,
    })),
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
        planName: isVi ? 'Chưa có gói' : 'No plan yet',
        status: 'inactive',
        renewal: '—',
      },
      payments: [],
    },
  };
}

export function createEmptyAdminDashboardData(): AdminDashboardData {
  return {
    metrics: [],
    userGrowth: [],
    contentEngagement: [],
    users: [],
    infra: [],
    content: [],
  };
}
