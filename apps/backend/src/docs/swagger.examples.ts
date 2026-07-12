import type { OpenAPIObject } from '@nestjs/swagger';

const SUCCESS_STATUS_CODES = ['200', '201'];
const METHODS = new Set(['get', 'post', 'put', 'patch', 'delete']);
const ISO_NOW = '2026-05-16T15:30:00.000Z';
const USER_ID = 'clx_user_01hv7q6y8e9r0t1y2u3i4o5p';
const RECORD_ID = 'clx_record_01hv7q6y8e9r0t1y2u3i4o5p';
const PUBLIC_ASSET_URL =
  'https://koshdbyfhivhpmydcgst.supabase.co/storage/v1/object/public/public-assets';

type JsonValue =
  | string
  | number
  | boolean
  | null
  | JsonValue[]
  | { [key: string]: JsonValue };

interface OpenApiOperation {
  tags?: string[];
  parameters?: OpenApiParameter[];
  requestBody?: OpenApiRequestBody;
  responses?: Record<string, OpenApiResponse>;
}

interface OpenApiParameter {
  name?: string;
  in?: string;
  example?: JsonValue;
  schema?: {
    example?: JsonValue;
    [key: string]: unknown;
  };
  [key: string]: unknown;
}

interface OpenApiRequestBody {
  content?: Record<string, OpenApiMediaType>;
  [key: string]: unknown;
}

interface OpenApiResponse {
  description?: string;
  content?: Record<string, OpenApiMediaType>;
  [key: string]: unknown;
}

interface OpenApiMediaType {
  schema?: unknown;
  example?: JsonValue;
  examples?: Record<string, { summary?: string; value: JsonValue }>;
}

const userExample = {
  id: USER_ID,
  email: 'thiai.chill@example.com',
  name: 'Thì Ai',
  avatar: `${PUBLIC_ASSET_URL}/avatars/thiai.png`,
  role: 'USER',
  authProvider: 'LOCAL',
  emailVerified: true,
  isActive: true,
  lastLoginAt: ISO_NOW,
  createdAt: '2026-05-10T08:00:00.000Z',
  updatedAt: ISO_NOW,
  profile: {
    id: 'clx_profile_01',
    userId: USER_ID,
    displayName: 'Thì Ai',
    bio: 'Đang tập sống chậm lại một chút.',
    birthday: '2000-05-20T00:00:00.000Z',
    zodiacSign: 'TAURUS',
    chineseZodiac: 'DRAGON',
    createdAt: '2026-05-10T08:00:00.000Z',
    updatedAt: ISO_NOW,
  },
  preferences: {
    id: 'clx_pref_01',
    userId: USER_ID,
    language: 'vi',
    timezone: 'Asia/Ho_Chi_Minh',
    latitude: 10.7769,
    longitude: 106.7009,
    locationName: 'Ho Chi Minh City',
    weatherEnabled: true,
    themeMode: 'SYSTEM',
    themeId: 'theme_pixel_purple',
    enableCompanionBubble: true,
    bubbleIntervalSeconds: 900,
    enableSound: true,
    enableHaptics: true,
    pushNotificationsEnabled: true,
    emailNotificationsEnabled: false,
    createdAt: '2026-05-10T08:00:00.000Z',
    updatedAt: ISO_NOW,
  },
};

const authResponseExample = {
  accessToken: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.example',
  refreshToken: '2b5ad8d4-5c3f-4a3e-9f8a-8f1dbdb5d2c1',
  expiresAt: '2026-06-15T15:30:00.000Z',
  user: userExample,
};

const profileExample = userExample.profile;
const preferenceExample = userExample.preferences;

const apiIndexExample = {
  name: 'Relax Before Stress Comes API',
  status: 'ok',
  version: '1.0.0',
  docs: {
    swagger: '/docs',
    openApiJson: '/docs-json',
  },
  health: '/health',
};

const sessionExample = {
  id: 'clx_session_01',
  userId: USER_ID,
  refreshToken: '2b5ad8d4-5c3f-4a3e-9f8a-8f1dbdb5d2c1',
  userAgent: 'RelaxApp/1.0 iOS',
  ipAddress: '203.0.113.10',
  expiresAt: '2026-06-15T15:30:00.000Z',
  createdAt: ISO_NOW,
  updatedAt: ISO_NOW,
  user: {
    id: USER_ID,
    email: 'thiai.chill@example.com',
    name: 'Thì Ai',
  },
};

const moodCheckinExample = {
  id: 'clx_mood_01',
  userId: USER_ID,
  mood: 'STRESSED',
  intensity: 4,
  rawScore: 78,
  finalScore: 61,
  scoredAt: ISO_NOW,
  note: 'Stress quá mới tìm đến tui hở?',
  tags: ['deadline', 'work'],
  createdAt: ISO_NOW,
  updatedAt: ISO_NOW,
};

const weeklyMoodStatExample = {
  id: 'clx_weekly_mood_01',
  userId: USER_ID,
  weekStart: '2026-05-11T00:00:00.000Z',
  avgScore: 58.4,
  stressReducePct: 18,
  streakDays: 12,
  dominantMood: 'CALM',
  createdAt: ISO_NOW,
};

const moodStatsExample = {
  total: 18,
  currentStreak: 12,
  longestStreak: 21,
  averageIntensity: 3.2,
  averageRawScore: 64.5,
  averageFinalScore: 52.1,
  stressReduction: 18,
  moodCounts: {
    HAPPY: 7,
    SAD: 2,
    STRESSED: 5,
    TIRED: 3,
    NEUTRAL: 1,
  },
};

const moodAnalyticsExample = {
  period: 'week',
  timezone: 'Asia/Ho_Chi_Minh',
  timezoneOffsetMinutes: 420,
  timeline: [
    { label: 'T2', date: '2026-05-11', avgScore: 62, dominantMood: 'TIRED' },
    { label: 'T3', date: '2026-05-12', avgScore: 58, dominantMood: 'STRESSED' },
    { label: 'T4', date: '2026-05-13', avgScore: 49, dominantMood: 'CALM' },
  ],
  weeklyStats: [weeklyMoodStatExample],
  streak: { current: 12, longest: 21 },
  delta: { stressReduction: 18, scoreChange: -9 },
};

const moodDashboardExample = {
  latest: moodCheckinExample,
  stats: moodStatsExample,
  analytics: moodAnalyticsExample,
  recommendedActions: [
    {
      type: 'BREATHING',
      title: 'Hít thở không khí',
      description: 'Hít thở sâu, thả lỏng cơ thể và sống chậm lại nào.',
    },
    {
      type: 'JOURNAL',
      title: 'Viết nhật kí',
      description: 'Ghi lại cảm xúc để nhẹ lòng hơn nhé.',
    },
  ],
};

const journalExample = {
  id: 'clx_journal_01',
  userId: USER_ID,
  title: 'Một chút nhẹ lòng',
  content: 'Hôm nay mình đã nghỉ lại vài phút và thấy dễ thở hơn.',
  mood: 'CALM',
  tags: ['self-care', 'evening'],
  isPrivate: true,
  isFavorite: false,
  createdAt: ISO_NOW,
  updatedAt: ISO_NOW,
};

const journalStatsExample = {
  total: 12,
  favorites: 3,
  privateEntries: 10,
  moodCounts: { CALM: 5, STRESSED: 4, HAPPY: 3 },
  topTags: [
    { tag: 'self-care', count: 6 },
    { tag: 'work', count: 4 },
  ],
};

const relaxActivityExample = {
  type: 'MUSIC',
  title: 'Nhạc',
  description: 'Những giai điệu nhẹ nhàng giúp tâm trí thư giãn.',
  iconKey: 'music-cassette',
  defaultDurationSeconds: 900,
  enabled: true,
};

const relaxSessionExample = {
  id: 'clx_relax_session_01',
  userId: USER_ID,
  activityType: 'MUSIC',
  status: 'FINISHED',
  resourceId: 'ambient_lofi_chill',
  title: 'Lo-fi Chill - Pixel Beats',
  startedAt: '2026-05-16T15:05:00.000Z',
  endedAt: ISO_NOW,
  duration: 1500,
  moodBefore: 'STRESSED',
  moodAfter: 'CALM',
  reliefLevel: 4,
  stressReliefPercent: 19,
  note: 'Nghe nhạc xong thấy nhẹ đầu hơn.',
  nextActionAccepted: 'PODCAST',
  createdAt: '2026-05-16T15:05:00.000Z',
  updatedAt: ISO_NOW,
};

const relaxStatsExample = {
  period: 'week',
  totalSessions: 9,
  totalDurationSeconds: 31320,
  totalDurationLabel: '8h 42m',
  favoriteActivityType: 'MUSIC',
  activityBreakdown: [
    { activityType: 'MUSIC', totalDurationSeconds: 12000, label: '3h 20m' },
    { activityType: 'PODCAST', totalDurationSeconds: 7800, label: '2h 10m' },
  ],
  recentSessions: [relaxSessionExample],
};

const companionAssetExample = {
  id: 'asset_pixel_cat_default',
  name: 'Pixel Cat Default',
  type: 'CAT',
  description: 'Pet pixel mặc định cho màn hình home.',
  previewImageUrl: `${PUBLIC_ASSET_URL}/companions/pixel-cat/preview.png`,
  spriteSheetUrl: `${PUBLIC_ASSET_URL}/companions/pixel-cat/sprite.png`,
  idleAnimationUrl: `${PUBLIC_ASSET_URL}/companions/pixel-cat/idle.gif`,
  sleepAnimationUrl: `${PUBLIC_ASSET_URL}/companions/pixel-cat/sleep.gif`,
  walkAnimationUrl: `${PUBLIC_ASSET_URL}/companions/pixel-cat/walk.gif`,
  primaryColor: '#7C5CFF',
  secondaryColor: '#BCA8FF',
  accentColor: '#FFB4A8',
  zodiacSign: null,
  chineseZodiac: null,
  isDefault: true,
  isActive: true,
  createdAt: ISO_NOW,
  updatedAt: ISO_NOW,
};

const userCompanionExample = {
  id: 'clx_user_companion_01',
  userId: USER_ID,
  assetId: companionAssetExample.id,
  name: 'Mon Leo',
  type: 'CAT',
  personalizationMode: 'DEFAULT',
  mood: 'CHILL',
  action: 'IDLE',
  level: 3,
  affection: 72,
  energy: 88,
  lastSeenAt: ISO_NOW,
  lastFedAt: '2026-05-16T12:00:00.000Z',
  lastMoodAt: ISO_NOW,
  createdAt: '2026-05-10T08:00:00.000Z',
  updatedAt: ISO_NOW,
  asset: companionAssetExample,
};

const companionInteractionExample = {
  interaction: {
    id: 'clx_companion_interaction_01',
    userId: USER_ID,
    companionId: userCompanionExample.id,
    type: 'PET',
    metadata: { source: 'home', mood: 'STRESSED' },
    createdAt: ISO_NOW,
  },
  companion: userCompanionExample,
};

const appThemeExample = {
  id: 'theme_pixel_purple',
  name: 'Pixel Purple Light',
  mode: 'LIGHT',
  backgroundColor: '#F8F6FF',
  surfaceColor: '#FFFFFF',
  primaryColor: '#6D5DFB',
  secondaryColor: '#BCA8FF',
  accentColor: '#FFB4A8',
  textColor: '#261D55',
  mutedTextColor: '#7E76A6',
  isDefault: true,
  isActive: true,
  createdAt: ISO_NOW,
  updatedAt: ISO_NOW,
};

const onboardingSlideExample = {
  id: 'slide_welcome_01',
  title: 'Chào mừng quay lại',
  subtitle: 'Một góc nhỏ để bạn nghỉ nhẹ.',
  description:
    'Check-in cảm xúc, chọn hoạt động thư giãn và theo dõi tiến trình mỗi ngày.',
  imageUrl: `${PUBLIC_ASSET_URL}/onboarding/welcome.png`,
  animationUrl: `${PUBLIC_ASSET_URL}/onboarding/welcome.json`,
  displayOrder: 1,
  isActive: true,
  createdAt: ISO_NOW,
  updatedAt: ISO_NOW,
};

const companionMessageExample = {
  id: 'message_after_checkin_01',
  content: 'Stress quá mới tìm đến tui hở? Bạn kể tui nghe đi nè!',
  triggerType: 'AFTER_CHECKIN',
  mood: 'STRESSED',
  companionMood: 'CURIOUS',
  minHour: 6,
  maxHour: 23,
  weight: 10,
  isActive: true,
  createdAt: ISO_NOW,
  updatedAt: ISO_NOW,
};

const ambientSoundExample = {
  id: 'ambient_lofi_chill',
  title: 'Lo-fi Chill - Pixel Beats',
  description: 'Nhạc nền nhẹ để thả lỏng đầu óc.',
  category: 'music',
  soundUrl: `${PUBLIC_ASSET_URL}/sounds/lofi-chill.mp3`,
  imageUrl: `${PUBLIC_ASSET_URL}/sounds/lofi-cover.png`,
  duration: 210,
  isActive: true,
  createdAt: ISO_NOW,
  updatedAt: ISO_NOW,
};

const breathingExerciseExample = {
  id: 'breathing_box_01',
  title: 'Box Breathing',
  description: 'Hít vào, giữ, thở ra đều nhịp để cơ thể dịu xuống.',
  inhaleSeconds: 4,
  holdSeconds: 4,
  exhaleSeconds: 4,
  cycles: 6,
  duration: 72,
  imageUrl: `${PUBLIC_ASSET_URL}/breathing/box.png`,
  isActive: true,
  createdAt: ISO_NOW,
  updatedAt: ISO_NOW,
};

const cozyQuoteExample = {
  id: 'quote_calm_01',
  content:
    'Không cần phải ổn hết mọi ngày, chỉ cần tốt hơn một chút so với chính mình hôm qua.',
  author: 'Thì Ai Chill',
  mood: 'CALM',
  imageUrl: `${PUBLIC_ASSET_URL}/quotes/calm.png`,
  isActive: true,
  createdAt: ISO_NOW,
  updatedAt: ISO_NOW,
};

const weatherExample = {
  configured: true,
  provider: 'open-meteo',
  location: {
    latitude: 10.7769,
    longitude: 106.7009,
    name: 'Ho Chi Minh City',
    timezone: 'Asia/Ho_Chi_Minh',
  },
  reverseGeocode: {
    provider: 'bigdatacloud',
    latitude: 10.7769,
    longitude: 106.7009,
    locationName: 'Thành phố Hồ Chí Minh',
    city: 'Thành phố Hồ Chí Minh',
    locality: 'Quận 1',
    principalSubdivision: 'Thành phố Hồ Chí Minh',
    countryName: 'Việt Nam',
    countryCode: 'VN',
    lookupSource: 'coordinates',
  },
  current: {
    temperature: 31.2,
    temperatureUnit: '°C',
    weatherCode: 1,
    isDay: true,
    observedAt: '2026-05-16T22:30',
  },
  greeting: {
    title: 'Đã trở lại rồi nè, bạn ~',
    titleTemplate: 'Đã trở lại rồi nè, {{name}} ~',
    displayName: null,
    subtitle: 'Trời nắng đẹp ghê!',
    iconKey: 'weather-sunny',
  },
};

const reverseGeocodeExample = {
  provider: 'bigdatacloud',
  latitude: 10.7769,
  longitude: 106.7009,
  locationName: 'Thành phố Hồ Chí Minh',
  city: 'Thành phố Hồ Chí Minh',
  locality: 'Quận 1',
  principalSubdivision: 'Thành phố Hồ Chí Minh',
  countryName: 'Việt Nam',
  countryCode: 'VN',
  lookupSource: 'coordinates',
};

const updateWeatherLocationExample = {
  preferences: {
    ...preferenceExample,
    latitude: 10.7769,
    longitude: 106.7009,
    locationName: 'Thành phố Hồ Chí Minh',
    timezone: 'Asia/Ho_Chi_Minh',
    weatherEnabled: true,
  },
  reverseGeocode: reverseGeocodeExample,
  weather: weatherExample,
};

const weatherForecastExample = {
  ...weatherExample,
  forecast: [
    {
      date: '2026-05-16',
      weatherCode: 1,
      iconKey: 'weather-sunny',
      title: 'Trời nắng đẹp',
      temperatureMax: 33.1,
      temperatureMin: 26.4,
      temperatureUnit: '°C',
      precipitationProbability: 20,
      precipitationProbabilityUnit: '%',
    },
    {
      date: '2026-05-17',
      weatherCode: 61,
      iconKey: 'weather-rain',
      title: 'Mưa nhẹ ngoài kia rồi nè',
      temperatureMax: 31.2,
      temperatureMin: 25.8,
      temperatureUnit: '°C',
      precipitationProbability: 68,
      precipitationProbabilityUnit: '%',
    },
  ],
};

const storageFileExample = {
  id: 'clx_storage_file_01',
  userId: USER_ID,
  filename: 'avatar.png',
  mimetype: 'image/png',
  size: 245760,
  provider: 'supabase',
  bucket: 'public-assets',
  path: `user-uploads/${USER_ID}/avatars/avatar.png`,
  url: `${PUBLIC_ASSET_URL}/user-uploads/${USER_ID}/avatars/avatar.png`,
  publicUrl: `${PUBLIC_ASSET_URL}/user-uploads/${USER_ID}/avatars/avatar.png`,
  isPublic: true,
  expiresAt: null,
  metadata: { domain: 'profile', state: 'avatar' },
  createdAt: ISO_NOW,
  updatedAt: ISO_NOW,
};

const notificationExample = {
  id: 'clx_notification_01',
  userId: USER_ID,
  title: 'Đến giờ check-in rồi nè',
  message: 'Dừng lại một chút để hỏi lòng mình đang thế nào nha.',
  type: 'PUSH',
  isRead: false,
  readAt: null,
  createdAt: ISO_NOW,
};

const reminderExample = {
  id: 'clx_reminder_01',
  userId: USER_ID,
  title: 'Uống nước một chút nha',
  message: 'Một ngụm nước nhỏ cũng giúp cơ thể dịu lại.',
  type: 'WATER',
  scheduledAt: '2026-05-17T09:00:00.000Z',
  repeatRule: '0 9 * * *',
  isActive: true,
  createdAt: ISO_NOW,
  updatedAt: ISO_NOW,
};

const pushDeviceExample = {
  id: 'clx_push_device_01',
  userId: USER_ID,
  token: 'fcm-device-token-example',
  platform: 'IOS',
  provider: 'FCM',
  deviceId: 'iphone-15-pro-abc',
  deviceName: 'iPhone của Thì Ai',
  appVersion: '1.0.0',
  timezone: 'Asia/Ho_Chi_Minh',
  enabled: true,
  lastSeenAt: ISO_NOW,
  createdAt: ISO_NOW,
  updatedAt: ISO_NOW,
};

const notificationProviderStatusExample = {
  push: {
    configured: false,
    providers: {
      FCM: {
        configured: false,
        missingKeys: ['FCM_SERVER_KEY', 'FIREBASE_SERVICE_ACCOUNT_JSON'],
        note: 'FCM chỉ cần một trong hai key.',
      },
      APNS: {
        configured: false,
        missingKeys: [
          'APNS_KEY_ID',
          'APNS_TEAM_ID',
          'APNS_BUNDLE_ID',
          'APNS_PRIVATE_KEY',
        ],
      },
      EXPO: {
        configured: false,
        missingKeys: ['EXPO_ACCESS_TOKEN'],
      },
    },
  },
  email: {
    configured: false,
    provider: 'none',
    missingKeys: ['RESEND_API_KEY', 'SENDGRID_API_KEY', 'SMTP_URL'],
    note: 'Email chỉ cần một provider thật khi deploy.',
  },
};

const billingProviderStatusExample = {
  configured: false,
  providers: {
    STRIPE: {
      configured: false,
      missingKeys: ['STRIPE_SECRET_KEY'],
    },
    APP_STORE: {
      configured: false,
      missingKeys: ['APPLE_SHARED_SECRET', 'APP_STORE_CONNECT_API_KEY'],
      note: 'App Store chỉ cần một trong các cấu hình receipt validation.',
    },
    GOOGLE_PLAY: {
      configured: false,
      missingKeys: ['GOOGLE_PLAY_SERVICE_ACCOUNT_JSON'],
    },
  },
};

const billingPlanExample = {
  name: 'CHILL_PLUS',
  title: 'Chill Plus',
  price: 49000,
  currency: 'VND',
  features: [
    'Thống kê nâng cao',
    'Companion custom',
    'Kho âm thanh mở rộng',
    'Reminder thông minh',
  ],
};

const weeklyMoodStatsJobExample = {
  job: 'weekly-mood-stats',
  startedAt: ISO_NOW,
  finishedAt: ISO_NOW,
  processedUsers: 1,
  failedUsers: 0,
  results: [
    {
      userId: USER_ID,
      timezone: 'Asia/Ho_Chi_Minh',
      timezoneOffsetMinutes: 420,
      recalculatedCount: 1,
      recalculatedWeeks: [weeklyMoodStatExample],
    },
  ],
  errors: [],
};

const queueStatusExample = {
  configured: true,
  enabled: true,
  provider: 'bullmq',
  redisUrl: 'redis://localhost:6379',
  prefix: 'dcb',
  defaultAttempts: 3,
  backoffDelayMs: 1000,
  registeredQueues: ['weekly-mood-stats'],
};

const realtimeStatusExample = {
  configured: true,
  provider: 'socket.io',
  namespace: '/realtime',
  adapter: {
    provider: 'socket.io',
    namespace: '/realtime',
    mode: 'redis',
    redisConfigured: true,
    redisConnected: true,
  },
  connectedClients: 0,
};

const analyticsContractsExample = {
  moodScore: {
    scale: '0-100',
    meaning: 'Điểm càng cao càng căng thẳng; điểm càng thấp càng thư giãn.',
    rawScore: 'Điểm thô khi người dùng chọn mood/mức độ trước activity.',
    finalScore: 'Điểm sau khi hoàn thành activity/check-in relief.',
    effectiveScore: 'finalScore ?? rawScore ?? scoreFromMood(mood)',
  },
  weeklyMoodStat: {
    weekStartsOn: 'MONDAY',
    timezoneSource:
      'query.timezone > userPreference.timezone > Asia/Ho_Chi_Minh',
    avgScore: 'Trung bình effectiveScore trong tuần theo timezone user.',
    stressReducePct:
      'previousWeekAvgScore - currentWeekAvgScore. Số dương nghĩa là stress giảm.',
  },
};

function pageExample<T extends JsonValue>(items: T[], total = items.length) {
  return {
    items,
    total,
    skip: 0,
    limit: 20,
    hasMore: false,
  };
}

const schemaRequestExamples: Record<string, JsonValue> = {
  RegisterDto: {
    email: 'thiai.chill@example.com',
    password: 'Secret123!x',
    name: 'Thì Ai',
  },
  LoginDto: {
    email: 'thiai.chill@example.com',
    password: 'Secret123!x',
  },
  RefreshTokenDto: {
    refreshToken: '2b5ad8d4-5c3f-4a3e-9f8a-8f1dbdb5d2c1',
  },
  RequestPasswordResetDto: {
    email: 'thiai.chill@example.com',
  },
  ResetPasswordDto: {
    token: 'dev-reset-token-from-request',
    password: 'NewSecret123!x',
  },
  VerifyEmailDto: {
    token: 'dev-email-verification-token-from-request',
  },
  DeleteAccountDto: {
    mode: 'SOFT',
    password: 'Secret123!x',
  },
  CreateUserDto: {
    email: 'friend@example.com',
    name: 'Bạn Chill',
    avatar: `${PUBLIC_ASSET_URL}/avatars/friend.png`,
    password: 'Secret123!x',
    role: 'USER',
    authProvider: 'LOCAL',
    emailVerified: false,
    isActive: true,
  },
  UpdateUserDto: {
    name: 'Bạn Chill Updated',
    avatar: `${PUBLIC_ASSET_URL}/avatars/friend-updated.png`,
    isActive: true,
  },
  UpsertUserProfileDto: {
    displayName: 'Thì Ai',
    bio: 'Đang tập sống chậm lại một chút.',
    birthday: '2000-05-20T00:00:00.000Z',
  },
  UpsertUserPreferenceDto: {
    language: 'vi',
    timezone: 'Asia/Ho_Chi_Minh',
    latitude: 10.7769,
    longitude: 106.7009,
    locationName: 'Ho Chi Minh City',
    weatherEnabled: true,
    themeMode: 'SYSTEM',
    themeId: 'theme_pixel_purple',
    enableCompanionBubble: true,
    bubbleIntervalSeconds: 900,
    enableSound: true,
    enableHaptics: true,
    pushNotificationsEnabled: true,
    emailNotificationsEnabled: false,
  },
  CreateMoodCheckinDto: {
    mood: 'STRESSED',
    intensity: 4,
    note: 'Stress quá mới tìm đến tui hở?',
    tags: ['deadline', 'work'],
  },
  UpdateMoodCheckinDto: {
    mood: 'CALM',
    intensity: 2,
    note: 'Đã nhẹ hơn sau khi nghe nhạc.',
    tags: ['music', 'relieved'],
  },
  RecalculateWeeklyMoodStatsDto: {
    from: '2026-05-11T00:00:00.000Z',
    to: '2026-05-17T23:59:59.999Z',
    timezone: 'Asia/Ho_Chi_Minh',
  },
  CreateJournalDto: {
    title: 'Một chút nhẹ lòng',
    content: 'Hôm nay mình đã nghỉ lại vài phút và thấy dễ thở hơn.',
    mood: 'CALM',
    tags: ['self-care', 'evening'],
    isPrivate: true,
    isFavorite: false,
  },
  UpdateJournalDto: {
    title: 'Một chút nhẹ lòng hơn',
    content: 'Mình thử viết thêm vài dòng sau buổi thư giãn.',
    mood: 'CALM',
    tags: ['self-care', 'music'],
    isFavorite: true,
  },
  StartRelaxSessionDto: {
    activityType: 'MUSIC',
    resourceId: 'ambient_lofi_chill',
    title: 'Lo-fi Chill - Pixel Beats',
    moodBefore: 'STRESSED',
  },
  FinishRelaxSessionDto: {
    moodAfter: 'CALM',
    reliefLevel: 4,
    note: 'Nghe nhạc xong thấy nhẹ đầu hơn.',
    nextActionAccepted: 'PODCAST',
  },
  UpsertUserCompanionDto: {
    assetId: companionAssetExample.id,
    name: 'Mon Leo',
    type: 'CAT',
    personalizationMode: 'CHINESE_ZODIAC',
    mood: 'CHILL',
    action: 'IDLE',
    level: 3,
    affection: 72,
    energy: 88,
  },
  CreateCompanionInteractionDto: {
    type: 'PET',
    metadata: { source: 'home', mood: 'STRESSED' },
  },
  SwitchCompanionPersonalizationDto: {
    personalizationMode: 'CHINESE_ZODIAC',
    preserveProgress: true,
    resetVisualState: true,
  },
  RegisterPushDeviceDto: {
    token: 'fcm-device-token-example',
    platform: 'IOS',
    provider: 'FCM',
    deviceId: 'iphone-15-pro-abc',
    deviceName: 'iPhone của Thì Ai',
    appVersion: '1.0.0',
    timezone: 'Asia/Ho_Chi_Minh',
    enabled: true,
  },
  CreateNotificationDto: {
    title: 'Đến giờ check-in rồi nè',
    message: 'Dừng lại một chút để hỏi lòng mình đang thế nào nha.',
    type: 'PUSH',
  },
  CreateReminderDto: {
    title: 'Uống nước một chút nha',
    message: 'Một ngụm nước nhỏ cũng giúp cơ thể dịu lại.',
    type: 'WATER',
    scheduledAt: '2026-05-17T09:00:00.000Z',
    repeatRule: '0 9 * * *',
    isActive: true,
  },
  UpdateReminderDto: {
    scheduledAt: '2026-05-17T10:00:00.000Z',
    isActive: true,
  },
  RunWeeklyMoodStatsJobDto: {
    userId: USER_ID,
    from: '2026-05-11T00:00:00.000Z',
    to: '2026-05-17T23:59:59.999Z',
    timezone: 'Asia/Ho_Chi_Minh',
    limit: 100,
  },
  CreateCheckoutSessionDto: {
    planName: 'CHILL_PLUS',
    provider: 'STRIPE',
    description: 'Upgrade to Chill Plus monthly',
  },
  CreateSignedUploadUrlDto: {
    path: 'avatars/avatar.png',
    upsert: false,
  },
  RegisterStorageFileDto: {
    filename: 'avatar.png',
    mimetype: 'image/png',
    size: 245760,
    path: 'avatars/avatar.png',
    publicUrl: `${PUBLIC_ASSET_URL}/user-uploads/${USER_ID}/avatars/avatar.png`,
    isPublic: true,
    metadata: { domain: 'profile', state: 'avatar' },
  },
  RemoveStorageObjectDto: {
    paths: ['companions/old-pixel-cat.png'],
  },
  UpdateWeatherLocationDto: {
    latitude: 10.7769,
    longitude: 106.7009,
    timezone: 'Asia/Ho_Chi_Minh',
    reverseGeocode: true,
    localityLanguage: 'vi',
    weatherEnabled: true,
  },
  CreateAppThemeDto: {
    name: 'Pixel Purple Light',
    mode: 'LIGHT',
    backgroundColor: '#F8F6FF',
    surfaceColor: '#FFFFFF',
    primaryColor: '#6D5DFB',
    secondaryColor: '#BCA8FF',
    accentColor: '#FFB4A8',
    textColor: '#261D55',
    mutedTextColor: '#7E76A6',
    isDefault: true,
    isActive: true,
  },
  UpdateAppThemeDto: {
    primaryColor: '#7C5CFF',
    accentColor: '#FFB4A8',
    isDefault: true,
  },
  CreateOnboardingSlideDto: {
    title: 'Chào mừng quay lại',
    subtitle: 'Một góc nhỏ để bạn nghỉ nhẹ.',
    description:
      'Check-in cảm xúc, chọn hoạt động thư giãn và theo dõi tiến trình mỗi ngày.',
    imageUrl: `${PUBLIC_ASSET_URL}/onboarding/welcome.png`,
    animationUrl: `${PUBLIC_ASSET_URL}/onboarding/welcome.json`,
    displayOrder: 1,
    isActive: true,
  },
  UpdateOnboardingSlideDto: {
    title: 'Chào mừng quay lại nhé',
    displayOrder: 2,
    isActive: true,
  },
  CreateCompanionAssetDto: {
    name: 'Pixel Cat Default',
    type: 'CAT',
    description: 'Pet pixel mặc định cho màn hình home.',
    previewImageUrl: `${PUBLIC_ASSET_URL}/companions/pixel-cat/preview.png`,
    spriteSheetUrl: `${PUBLIC_ASSET_URL}/companions/pixel-cat/sprite.png`,
    idleAnimationUrl: `${PUBLIC_ASSET_URL}/companions/pixel-cat/idle.gif`,
    sleepAnimationUrl: `${PUBLIC_ASSET_URL}/companions/pixel-cat/sleep.gif`,
    walkAnimationUrl: `${PUBLIC_ASSET_URL}/companions/pixel-cat/walk.gif`,
    primaryColor: '#7C5CFF',
    secondaryColor: '#BCA8FF',
    accentColor: '#FFB4A8',
    isDefault: true,
    isActive: true,
  },
  UpdateCompanionAssetDto: {
    name: 'Pixel Cat Night',
    sleepAnimationUrl: `${PUBLIC_ASSET_URL}/companions/pixel-cat/sleep-night.gif`,
    isActive: true,
  },
  CreateCompanionMessageDto: {
    content: 'Stress quá mới tìm đến tui hở? Bạn kể tui nghe đi nè!',
    triggerType: 'AFTER_CHECKIN',
    mood: 'STRESSED',
    companionMood: 'CURIOUS',
    minHour: 6,
    maxHour: 23,
    weight: 10,
    isActive: true,
  },
  UpdateCompanionMessageDto: {
    content: 'Mình ở đây nghe bạn nè.',
    companionMood: 'CALM',
    weight: 8,
    isActive: true,
  },
  CreateAmbientSoundDto: {
    title: 'Lo-fi Chill - Pixel Beats',
    description: 'Nhạc nền nhẹ để thả lỏng đầu óc.',
    category: 'music',
    soundUrl: `${PUBLIC_ASSET_URL}/sounds/lofi-chill.mp3`,
    imageUrl: `${PUBLIC_ASSET_URL}/sounds/lofi-cover.png`,
    duration: 210,
    isActive: true,
  },
  UpdateAmbientSoundDto: {
    title: 'Lo-fi Chill - Pixel Beats Extended',
    duration: 240,
    isActive: true,
  },
  CreateBreathingExerciseDto: {
    title: 'Box Breathing',
    description: 'Hít vào, giữ, thở ra đều nhịp để cơ thể dịu xuống.',
    inhaleSeconds: 4,
    holdSeconds: 4,
    exhaleSeconds: 4,
    cycles: 6,
    duration: 72,
    imageUrl: `${PUBLIC_ASSET_URL}/breathing/box.png`,
    isActive: true,
  },
  UpdateBreathingExerciseDto: {
    title: 'Box Breathing 4-4-4',
    cycles: 8,
    duration: 96,
    isActive: true,
  },
  CreateCozyQuoteDto: {
    content:
      'Không cần phải ổn hết mọi ngày, chỉ cần tốt hơn một chút so với chính mình hôm qua.',
    author: 'Thì Ai Chill',
    mood: 'CALM',
    imageUrl: `${PUBLIC_ASSET_URL}/quotes/calm.png`,
    isActive: true,
  },
  UpdateCozyQuoteDto: {
    mood: 'STRESSED',
    isActive: true,
  },
};

const parameterExamples: Record<string, JsonValue> = {
  id: RECORD_ID,
  userId: USER_ID,
  category: 'music',
  mood: 'STRESSED',
  path: 'companions/pixel-cat.png',
  localityLanguage: 'vi',
  expiresIn: 3600,
  deep: true,
  latitude: 10.7769,
  longitude: 106.7009,
  timezone: 'Asia/Ho_Chi_Minh',
  forecastDays: 7,
  period: 'week',
  timezoneOffsetMinutes: 420,
  activityType: 'MUSIC',
  from: '2026-05-11T00:00:00.000Z',
  to: '2026-05-16T23:59:59.999Z',
  skip: 0,
  limit: 20,
  tag: 'self-care',
  isFavorite: true,
  compare: true,
};

export function applyExampleDocumentation(document: OpenAPIObject) {
  for (const [path, pathItem] of Object.entries(document.paths)) {
    for (const [method, operation] of Object.entries(pathItem)) {
      if (!METHODS.has(method)) {
        continue;
      }

      const typedOperation = operation as OpenApiOperation;
      applyParameterExamples(typedOperation);
      applyRequestBodyExample(typedOperation);
      applySuccessResponseExample(path, method, typedOperation);
    }
  }
}

function applyParameterExamples(operation: OpenApiOperation) {
  for (const parameter of operation.parameters ?? []) {
    const example = parameter.name
      ? parameterExamples[parameter.name]
      : undefined;
    if (example === undefined) {
      continue;
    }

    parameter.example ??= example;
    parameter.schema ??= {};
    parameter.schema.example ??= example;
  }
}

function applyRequestBodyExample(operation: OpenApiOperation) {
  const jsonContent = operation.requestBody?.content?.['application/json'];
  if (!jsonContent) {
    return;
  }

  const schemaName = getSchemaRefName(jsonContent.schema);
  const example = schemaName ? schemaRequestExamples[schemaName] : undefined;
  if (!example) {
    return;
  }

  jsonContent.example ??= example;
  jsonContent.examples ??= {
    default: {
      summary: 'Mẫu request body',
      value: example,
    },
  };
}

function applySuccessResponseExample(
  path: string,
  method: string,
  operation: OpenApiOperation,
) {
  operation.responses ??= {};
  const statusCode =
    SUCCESS_STATUS_CODES.find((code) => operation.responses?.[code]) ?? '200';
  const response = (operation.responses[statusCode] ??= {
    description: 'Successful response.',
  });

  const example = getResponseExample(path, method, operation.tags?.[0]);
  if (example === undefined) {
    return;
  }

  response.content ??= {};
  response.content['application/json'] ??= {
    schema: Array.isArray(example) ? { type: 'array' } : { type: 'object' },
  };

  const jsonContent = response.content['application/json'];
  jsonContent.example ??= example;
  jsonContent.examples ??= {
    default: {
      summary: 'Mẫu response thành công',
      value: example,
    },
  };
}

function getSchemaRefName(schema: unknown) {
  if (!schema || typeof schema !== 'object' || !('$ref' in schema)) {
    return undefined;
  }

  const ref = (schema as { $ref?: string }).$ref;
  return ref?.split('/').at(-1);
}

function getResponseExample(
  path: string,
  method: string,
  tag?: string,
): JsonValue | undefined {
  if (path === '/' || path === '/api') return apiIndexExample;
  if (path === '/health') {
    return {
      status: 'ok',
      timestamp: ISO_NOW,
      uptimeSeconds: 42,
    };
  }
  if (path === '/ready') {
    return {
      status: 'ok',
      timestamp: ISO_NOW,
      checks: {
        database: { ok: true, latencyMs: 8 },
        storage: { configured: true, bucket: 'public-assets' },
      },
    };
  }

  if (tag === 'Auth') {
    if (path === '/auth/logout') return { success: true };
    if (path === '/auth/password-reset/request') {
      return {
        success: true,
        delivery: {
          channel: 'email',
          purpose: 'PASSWORD_RESET',
          provider: 'none',
          configured: false,
          queued: false,
          devToken: 'dev-reset-token-from-request',
        },
      };
    }
    if (path === '/auth/password-reset/confirm') {
      return { success: true, revokedSessions: true, user: userExample };
    }
    if (path === '/auth/email/verify') {
      return { success: true, user: { ...userExample, emailVerified: true } };
    }
    if (path === '/auth/me/email-verification') {
      return {
        success: true,
        alreadyVerified: false,
        expiresAt: '2026-05-17T15:30:00.000Z',
        delivery: {
          channel: 'email',
          purpose: 'EMAIL_VERIFICATION',
          provider: 'none',
          configured: false,
          queued: false,
          devToken: 'dev-email-verification-token-from-request',
        },
      };
    }
    if (path === '/auth/me' && method === 'delete') {
      return {
        success: true,
        mode: 'SOFT',
        revokedSessions: true,
        anonymized: true,
      };
    }
    if (path === '/auth/me') return userExample;
    return authResponseExample;
  }

  if (tag === 'Users')
    return method === 'get' && path === '/users'
      ? pageExample([userExample])
      : userExample;
  if (tag === 'User Profiles') return profileExample;
  if (tag === 'User Preferences') return preferenceExample;
  if (tag === 'Sessions') {
    if (path === '/sessions/user/{userId}' && method === 'delete')
      return { count: 3 };
    if (method === 'get') return [sessionExample];
    return sessionExample;
  }

  if (tag === 'Mood Check-ins') {
    if (path.endsWith('/options')) {
      return [
        {
          mood: 'HAPPY',
          label: 'Vui vẻ',
          iconKey: 'mood-happy',
          defaultRawScore: 25,
          recommendedActions: ['MUSIC', 'JOURNAL'],
        },
        {
          mood: 'STRESSED',
          label: 'Stress',
          iconKey: 'mood-stressed',
          defaultRawScore: 78,
          recommendedActions: ['BREATHING', 'MEDITATION'],
        },
      ];
    }
    if (path.includes('/weekly-stats/recalculate')) {
      return {
        userId: USER_ID,
        timezone: 'Asia/Ho_Chi_Minh',
        timezoneOffsetMinutes: 420,
        recalculatedCount: 2,
        recalculatedWeeks: [weeklyMoodStatExample],
      };
    }
    if (path.includes('/weekly-stats')) return [weeklyMoodStatExample];
    if (path.includes('/analytics')) return moodAnalyticsExample;
    if (path.includes('/dashboard')) return moodDashboardExample;
    if (path.includes('/recommendations')) {
      return [
        {
          type: 'BREATHING',
          title: 'Hít thở không khí',
          description: 'Hít thở sâu, thả lỏng cơ thể và sống chậm lại nào.',
        },
      ];
    }
    if (path.includes('/stats')) return moodStatsExample;
    if (
      method === 'get' &&
      (path === '/mood-checkins' ||
        path === '/mood-checkins/me' ||
        path.includes('/user/'))
    ) {
      return pageExample([moodCheckinExample]);
    }
    return moodCheckinExample;
  }

  if (tag === 'Journals') {
    if (path.includes('/stats')) return journalStatsExample;
    if (
      method === 'get' &&
      (path === '/journals/me' || path.includes('/user/'))
    ) {
      return pageExample([journalExample]);
    }
    return journalExample;
  }

  if (tag === 'Relax Activities') {
    if (path === '/relax-activities') return [relaxActivityExample];
    if (path.includes('/stats')) return relaxStatsExample;
    if (path.includes('/sessions') && method === 'get')
      return pageExample([relaxSessionExample]);
    return relaxSessionExample;
  }

  if (tag === 'Relax Sessions') {
    if (path.includes('/stats')) return relaxStatsExample;
    if (method === 'get') return [relaxSessionExample];
    return relaxSessionExample;
  }

  if (tag === 'User Companions') {
    if (path.includes('/interactions')) return companionInteractionExample;
    if (path.includes('/personalization-mode')) {
      return {
        companion: {
          ...userCompanionExample,
          personalizationMode: 'CHINESE_ZODIAC',
        },
        transition: {
          fromMode: 'DEFAULT',
          toMode: 'CHINESE_ZODIAC',
          fromAssetId: 'asset_pixel_cat_default',
          toAssetId: 'asset_chinese_dragon',
          preserveProgress: true,
          resetVisualState: true,
          rule: 'Giữ level/affection/energy khi đổi linh thú.',
        },
      };
    }
    if (path.includes('/personalization-options')) {
      return {
        profile: {
          birthday: '2000-05-20T00:00:00.000Z',
          zodiacSign: 'Taurus',
          chineseZodiac: 'Dragon',
        },
        modes: [
          {
            mode: 'DEFAULT',
            label: 'Mặc định',
            available: true,
            assets: [companionAssetExample],
          },
          {
            mode: 'ZODIAC',
            label: 'Theo cung hoàng đạo',
            key: 'Taurus',
            available: true,
            assets: [
              {
                ...companionAssetExample,
                id: 'asset_zodiac_taurus',
                name: 'Zodiac Tea Bull',
                zodiacSign: 'Taurus',
              },
            ],
          },
          {
            mode: 'CHINESE_ZODIAC',
            label: 'Theo 12 con giáp',
            key: 'Dragon',
            available: true,
            assets: [
              {
                ...companionAssetExample,
                id: 'asset_chinese_dragon',
                name: 'Chinese Zodiac Tiny Dragon',
                chineseZodiac: 'Dragon',
              },
            ],
          },
          {
            mode: 'CUSTOM',
            label: 'Tự chọn linh thú',
            available: true,
            assets: [],
          },
        ],
      };
    }
    if (path.includes('/stats')) {
      return {
        companion: userCompanionExample,
        totalInteractions: 24,
        recentInteractions: [companionInteractionExample.interaction],
      };
    }
    return userCompanionExample;
  }

  if (tag === 'Analytics') {
    if (path === '/analytics/contracts') return analyticsContractsExample;
    return {
      period: 'week',
      timezone: 'Asia/Ho_Chi_Minh',
      timezoneOffsetMinutes: 420,
      mood: moodAnalyticsExample,
      journals: journalStatsExample,
      relax: relaxStatsExample,
      companion: {
        companion: userCompanionExample,
        totalInteractions: 24,
        recentInteractions: [companionInteractionExample.interaction],
      },
      summaryCards: {
        currentStreak: 12,
        totalRelaxTime: '8h 42m',
        totalJournals: 12,
        companionAffection: 72,
        stressReduction: 18,
      },
    };
  }

  if (tag === 'Weather') {
    if (path.includes('/reverse-geocode')) return reverseGeocodeExample;
    if (path.includes('/me/location')) return updateWeatherLocationExample;
    return path.includes('/forecast') ? weatherForecastExample : weatherExample;
  }
  if (tag === 'Notifications') {
    if (path.includes('/providers')) return notificationProviderStatusExample;
    if (path.includes('/unread-count')) return { count: 3 };
    if (path.includes('/devices') && method === 'get')
      return [pushDeviceExample];
    if (path.includes('/devices') && method === 'delete')
      return { success: true, id: 'clx_push_device_01' };
    if (path.includes('/devices')) return pushDeviceExample;
    if (path.includes('/read-all')) return { success: true, count: 3 };
    if (path.includes('/test') || path.includes('/user/')) {
      return {
        notification: notificationExample,
        delivery: {
          channel: 'push',
          configured: false,
          queued: false,
          enabledDeviceCount: 1,
        },
      };
    }
    return method === 'get'
      ? pageExample([notificationExample])
      : notificationExample;
  }
  if (tag === 'Reminders') {
    if (path.includes('/stats')) {
      return {
        total: 3,
        active: 3,
        upcoming: 3,
        byType: [
          { type: 'WATER', count: 1 },
          { type: 'REST', count: 1 },
          { type: 'JOURNAL', count: 1 },
        ],
      };
    }
    if (method === 'get') return pageExample([reminderExample]);
    if (method === 'delete') return { success: true, id: reminderExample.id };
    return reminderExample;
  }
  if (tag === 'Jobs') {
    if (path.includes('/status')) {
      return {
        weeklyMoodStats: {
          enabled: false,
          intervalMs: 21600000,
          batchSize: 500,
          queue: {
            name: 'weekly-mood-stats',
            jobName: 'recalculate-weekly-mood-stats',
            workerEnabled: false,
            workerConcurrency: 2,
          },
          lastRun: null,
        },
      };
    }
    if (path.includes('/enqueue')) {
      return {
        queued: true,
        queue: 'weekly-mood-stats',
        jobName: 'recalculate-weekly-mood-stats',
        jobId: '42',
      };
    }
    return weeklyMoodStatsJobExample;
  }
  if (tag === 'Queues') return queueStatusExample;
  if (tag === 'Realtime') return realtimeStatusExample;
  if (tag === 'Billing') {
    if (path.includes('/providers')) return billingProviderStatusExample;
    if (path.includes('/plans')) return [billingPlanExample];
    if (path === '/billing/me') {
      return {
        subscription: {
          userId: USER_ID,
          status: 'ACTIVE',
          planName: 'FREE',
          price: 0,
          currency: 'VND',
        },
        providerStatus: billingProviderStatusExample,
      };
    }
    return {
      configured: false,
      provider: 'STRIPE',
      plan: {
        name: 'CHILL_PLUS',
        title: 'Chill Plus',
        price: 49000,
        currency: 'VND',
        source: 'subscription_tier',
      },
      payment: {
        id: 'clx_payment_01',
        userId: USER_ID,
        amount: 49000,
        currency: 'VND',
        status: 'PENDING',
        provider: 'STRIPE',
        description: 'Upgrade to Chill Plus monthly',
        createdAt: ISO_NOW,
        updatedAt: ISO_NOW,
      },
      checkout: {
        status: 'PROVIDER_NOT_CONFIGURED',
        note: 'Backend đã tạo payment pending. Cần cấu hình Stripe/App Store/Google Play để lấy checkout URL thật.',
      },
    };
  }
  if (tag === 'Storage') return getStorageResponseExample(path);
  if (tag === 'App Themes')
    return method === 'get' && path === '/app-themes'
      ? [appThemeExample]
      : appThemeExample;
  if (tag === 'Onboarding Slides')
    return method === 'get' ? [onboardingSlideExample] : onboardingSlideExample;
  if (tag === 'Companion Assets') {
    return method === 'get' && path === '/companion-assets'
      ? [companionAssetExample]
      : companionAssetExample;
  }
  if (tag === 'Companion Messages') {
    return method === 'get' && path === '/companion-messages'
      ? [companionMessageExample]
      : companionMessageExample;
  }
  if (tag === 'Ambient Sounds')
    return method === 'get' ? [ambientSoundExample] : ambientSoundExample;
  if (tag === 'Breathing Exercises') {
    return method === 'get'
      ? [breathingExerciseExample]
      : breathingExerciseExample;
  }
  if (tag === 'Cozy Quotes') {
    return method === 'get' &&
      (path === '/cozy-quotes' || path.includes('/mood/'))
      ? [cozyQuoteExample]
      : cozyQuoteExample;
  }

  return undefined;
}

function getStorageResponseExample(path: string): JsonValue {
  if (path === '/storage/health') {
    return {
      configured: true,
      provider: 'supabase',
      bucket: 'public-assets',
      missingKeys: [],
      invalidKeys: [],
      urlValid: true,
      bucketFound: true,
    };
  }

  if (path === '/storage/cdn-strategy') {
    return {
      provider: 'supabase',
      bucket: 'public-assets',
      publicBucket: true,
      defaultSignedUrlExpiresIn: 3600,
      pathConventions: {
        companions: 'companions/{asset-key}/{state}.png',
        onboarding: 'onboarding/{slide-key}.png',
        sounds: 'sounds/{category}/{sound-key}.mp3',
        breathing: 'breathing/{exercise-key}.png',
        quotes: 'quotes/{mood-key}.png',
        userUploads: 'user-uploads/{user-id}/{filename}',
      },
      accessRules: {
        catalogAssets:
          'public-url readable by users; writes and arbitrary path reads are admin-only',
        userUploads:
          'signed/public read URLs are scoped to user-uploads/{authenticatedUserId}/',
        adminDeletes: 'admin-only',
      },
      configured: true,
    };
  }

  if (path.includes('/admin/signed-upload-url')) {
    return {
      bucket: 'public-assets',
      path: 'companions/pixel-cat.png',
      signedUrl:
        'https://example.supabase.co/storage/v1/object/upload/sign/public-assets/companions/pixel-cat.png?token=...',
      token: 'signed-upload-token',
    };
  }

  if (path.includes('/signed-upload-url')) {
    return {
      bucket: 'public-assets',
      path: `user-uploads/${USER_ID}/avatars/avatar.png`,
      signedUrl:
        'https://example.supabase.co/storage/v1/object/upload/sign/public-assets/user-uploads/user-id/avatars/avatar.png?token=...',
      token: 'signed-upload-token',
    };
  }

  if (path.includes('/admin/signed-url')) {
    return {
      bucket: 'public-assets',
      path: 'companions/pixel-cat.png',
      signedUrl:
        'https://example.supabase.co/storage/v1/object/sign/public-assets/companions/pixel-cat.png?token=...',
      expiresIn: 3600,
    };
  }

  if (path.includes('/signed-url')) {
    return {
      bucket: 'public-assets',
      path: `user-uploads/${USER_ID}/avatars/avatar.png`,
      signedUrl:
        'https://example.supabase.co/storage/v1/object/sign/public-assets/user-uploads/user-id/avatars/avatar.png?token=...',
      expiresIn: 3600,
    };
  }

  if (path.includes('/admin/public-url')) {
    return {
      bucket: 'public-assets',
      path: 'companions/pixel-cat.png',
      publicUrl: `${PUBLIC_ASSET_URL}/companions/pixel-cat.png`,
    };
  }

  if (path.includes('/public-url')) {
    return {
      bucket: 'public-assets',
      path: `user-uploads/${USER_ID}/avatars/avatar.png`,
      publicUrl: `${PUBLIC_ASSET_URL}/user-uploads/user-id/avatars/avatar.png`,
    };
  }

  if (path === '/storage/files' || path === '/storage/me/files') {
    return [storageFileExample];
  }
  if (path.includes('/objects')) {
    return {
      bucket: 'public-assets',
      removed: [{ name: 'companions/old-pixel-cat.png' }],
    };
  }

  return storageFileExample;
}
