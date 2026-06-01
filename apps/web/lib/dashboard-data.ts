export type MoodOption = {
  type: string;
  label: string;
  icon: string;
  value: number;
  color: string;
};

export type UserDashboardData = {
  overview: {
    period: string;
    timezone: string;
    summaryCards: {
      currentStreak: number;
      totalRelaxTime: string;
      totalJournals: number;
      companionAffection: number;
      stressReduction: number;
    };
    mood: {
      currentMood: string;
      prompt: string;
      summary: {
        total: number;
        topMood: string;
        currentStreak: number;
        longestStreak: number;
        averageIntensity: number;
      };
      recommendations: string[];
    };
    journals: {
      total: number;
      favorites: number;
      recent: Array<{
        id: string;
        title: string;
        content: string;
        moodType: string;
        mood: string;
        tags: string[];
        excerpt: string;
        createdAt: string;
        favorite: boolean;
      }>;
      byMood: Array<{
        mood: string;
        count: number;
      }>;
    };
    relax: {
      totalSessions: number;
      totalDurationSeconds: number;
      totalDurationLabel: string;
      streak: number;
      relief: number;
      favoriteActivities: Array<{
        activityType: string;
        label: string;
        totalDurationSeconds: number;
        sessions: number;
      }>;
      recentMoments: Array<{
        title: string;
        time: string;
        duration: string;
        relief: number;
      }>;
    };
    companion: {
      level: number;
      affection: number;
      energy: number;
      mood: string;
      action: string;
      lastFedAt: string;
      totalInteractions: number;
      recentInteractions: Array<{
        action: string;
        label: string;
        at: string;
      }>;
    };
    weather: {
      greeting: {
        title: string;
        subtitle: string;
        iconKey: string;
      };
      current: {
        temperature: number;
        weatherCode: number;
        isDay: boolean;
      };
      forecast: Array<{
        day: string;
        temperature: number;
        rainChance: number;
      }>;
    };
    notifications: {
      unreadCount: number;
      list: Array<{
        title: string;
        type: string;
        read: boolean;
      }>;
    };
  };
  moodOptions: MoodOption[];
  moodHistory: Array<{
    id: string;
    createdAt: string;
    moodType: string;
    mood: string;
    note: string;
    intensity: number;
  }>;
  timeline: Array<{
    label: string;
    date: string;
    moodScore: number;
    stressScore: number;
    relaxMinutes: number;
    journals: number;
  }>;
  distribution: Array<{
    mood: string;
    count: number;
    percent: number;
  }>;
  weeklyStats: Array<{
    weekStart: string;
    avgScore: number;
    stressReducePct: number;
    streakDays: number;
    dominantMood: string;
  }>;
  relaxActivities: Array<{
    id: string;
    type: string;
    title: string;
    subtitle: string;
    duration: string;
    sessions: number;
    relief: number;
    resources: Array<{
      id: string;
      title: string;
      category: string;
      duration?: number | null;
    }>;
  }>;
  settings: {
    profile: {
      displayName: string;
      email: string;
      /** Public URL của ảnh đại diện (Supabase). Null khi chưa upload. */
      avatar: string | null;
      birthday: string;
      zodiacSign: string;
      chineseZodiac: string;
    };
    preferences: {
      theme: string;
      timezone: string;
      weatherEnabled: boolean;
      locationName: string;
      reminderTimes: string[];
      soundEnabled: boolean;
      pushEnabled: boolean;
      emailEnabled: boolean;
    };
    sessions: Array<{
      id: string;
      device: string;
      ipAddress: string;
      createdAt: string;
      expiresAt: string;
      current: boolean;
    }>;
    pushDevices: Array<{
      id: string;
      label: string;
      platform: string;
      active: boolean;
    }>;
    reminders: Array<{
      id: string;
      type: string;
      title: string;
      schedule: string;
      active: boolean;
    }>;
    billing: {
      planName: string;
      status: string;
      renewal: string;
    };
  };
};

export type AdminDashboardData = {
  metrics: Array<{
    label: string;
    value: string;
    delta: string;
  }>;
  userGrowth: Array<{
    label: string;
    users: number;
    active: number;
    revenue: number;
  }>;
  contentEngagement: Array<{
    name: string;
    value: number;
  }>;
  users: Array<{
    name: string;
    email: string;
    status: string;
    plan: string;
    streak: number;
    lastLogin: string;
  }>;
  infra: Array<{
    service: string;
    status: string;
    latency: string;
  }>;
  content: Array<{
    area: string;
    live: number;
    drafts: number;
    endpoint: string;
  }>;
};

export const userDashboardData: UserDashboardData = {
  overview: {
    period: '',
    timezone: '',
    summaryCards: {
      currentStreak: 0,
      totalRelaxTime: '0 phut',
      totalJournals: 0,
      companionAffection: 0,
      stressReduction: 0,
    },
    mood: {
      currentMood: 'Chưa có dữ liệu',
      prompt: 'Đang chờ dữ liệu thật từ backend.',
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
      totalDurationLabel: '0 phut',
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
  moodOptions: [
    { type: 'HAPPY', label: 'Vui vẻ', icon: 'sun', value: 70, color: '#f7c948' },
    { type: 'SAD', label: 'Buồn', icon: 'cloud', value: 25, color: '#7c8cf8' },
    { type: 'STRESSED', label: 'Stress', icon: 'zap', value: 65, color: '#ef767a' },
    { type: 'TIRED', label: 'Mệt mỏi', icon: 'moon', value: 40, color: '#9f7aea' },
    { type: 'ANXIOUS', label: 'Lo lắng', icon: 'battery', value: 30, color: '#40c9a2' },
    { type: 'NEUTRAL', label: 'Bình thường', icon: 'sparkles', value: 50, color: '#7357f6' },
    { type: 'CALM', label: 'Bình yên', icon: 'sparkles', value: 35, color: '#40c9a2' },
    { type: 'EXCITED', label: 'Hào hứng', icon: 'sparkles', value: 75, color: '#7357f6' },
    { type: 'LONELY', label: 'Cô đơn', icon: 'cloud', value: 45, color: '#7c8cf8' },
    { type: 'GRATEFUL', label: 'Biết ơn', icon: 'sun', value: 30, color: '#f7c948' },
  ],
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
      planName: '',
      status: '',
      renewal: '',
    },
  },
};

export const adminDashboardData: AdminDashboardData = {
  metrics: [],
  userGrowth: [],
  contentEngagement: [],
  users: [],
  infra: [],
  content: [],
};
