// Navigation
export interface NavItem {
  label: string;
  href: string;
}

// Chart data point
export interface MoodPoint {
  day: string;
  mood: number;
  stress: number;
}

// ── Auth ──────────────────────────────────────────────

export interface AuthResponse {
  accessToken: string;
  refreshToken?: string;
  user: UserSummary;
}

export interface UserSummary {
  id: string;
  email: string;
  name?: string;
  avatar?: string;
  role: 'ADMIN' | 'USER';
}

// ── Mood ──────────────────────────────────────────────

export type MoodType =
  | 'HAPPY'
  | 'CALM'
  | 'TIRED'
  | 'SAD'
  | 'ANXIOUS'
  | 'STRESSED'
  | 'EXCITED'
  | 'NEUTRAL'
  | 'LONELY'
  | 'GRATEFUL';

export type TriggerType =
  | 'WORK'
  | 'DEADLINE'
  | 'FAMILY'
  | 'MONEY'
  | 'SLEEP'
  | 'RELATIONSHIP'
  | 'HEALTH'
  | 'SOCIAL_MEDIA'
  | 'CRAVING'
  | 'UNKNOWN';

export interface MoodCheckin {
  id: string;
  userId: string;
  mood: MoodType;
  intensity?: number;
  note?: string;
  tags: string[];
  trigger?: TriggerType;
  createdAt: string;
}

// ── Journal ───────────────────────────────────────────

export interface JournalEntry {
  id: string;
  userId: string;
  title?: string;
  content: string;
  mood?: MoodType;
  tags: string[];
  isPrivate: boolean;
  isFavorite: boolean;
  createdAt: string;
}

// ── Relax Session ─────────────────────────────────────

export type RelaxActivityType =
  | 'MUSIC'
  | 'PODCAST'
  | 'JOURNAL'
  | 'BREATHING'
  | 'MYSTERY'
  | 'MEDITATION';

export type RelaxSessionStatus = 'STARTED' | 'FINISHED' | 'CANCELLED';

export interface RelaxSession {
  id: string;
  userId: string;
  activityType: RelaxActivityType;
  status: RelaxSessionStatus;
  title: string;
  startedAt: string;
  endedAt?: string;
  duration?: number;
  moodBefore?: MoodType;
  moodAfter?: MoodType;
  reliefLevel?: number;
  stressReliefPercent?: number;
}

// ── Recommendation ────────────────────────────────────

export interface Recommendation {
  type: string;
  title: string;
  reason: string;
  score: number;
  deepLink: string;
}

export interface RecommendationResponse {
  recommendations: Recommendation[];
  currentMood: MoodType;
  generatedAt: string;
}

// ── Content Rating ────────────────────────────────────

export interface ContentRating {
  id: string;
  contentType: string;
  contentId: string;
  rating: number;
  review?: string;
}

// ── Feature Flag ──────────────────────────────────────

export interface FeatureFlag {
  id: string;
  key: string;
  label: string;
  description?: string;
  enabled: boolean;
}

// ── Billing ───────────────────────────────────────────

export interface BillingPlan {
  id: string;
  name: string;
  title?: string;
  price: number;
  currency: string;
  billingCycle: 'MONTHLY' | 'ANNUAL';
  features: Array<{ name: string; included: boolean }>;
}

// ── Notification ──────────────────────────────────────

export interface AppNotification {
  id: string;
  title: string;
  message: string;
  type: 'IN_APP' | 'PUSH' | 'EMAIL' | 'SMS';
  isRead: boolean;
  createdAt: string;
}

// ── Experiment ────────────────────────────────────────

export interface Experiment {
  id: string;
  key: string;
  name: string;
  description?: string;
  variants: string[];
  isActive: boolean;
}

export interface ExperimentAssignment {
  experiment: Experiment;
  variant: string;
}

// ── Ops ───────────────────────────────────────────────

export interface OpsStatus {
  status: 'ok' | 'degraded';
  timestamp: string;
  uptimeSeconds: number;
  api: { status: string };
  database: { connected: boolean; latencyMs: number };
  redis: {
    connected: boolean;
    configured: boolean;
    latencyMs: number | null;
  };
  queue: {
    configured: boolean;
    enabled: boolean;
    registeredQueues: string[];
  };
  providers: {
    push: { ready: boolean };
    email: { ready: boolean };
    billing: { ready: boolean };
    storage: { ready: boolean; bucket?: string };
  };
  users: { total: number; activeToday: number };
  lastWeeklyStatsJob: {
    success: boolean;
    processedUsers: number;
    ranAt: string;
  } | null;
}

// ── Paginated Response ────────────────────────────────

export interface PaginatedResponse<T> {
  items: T[];
  total: number;
  page: number;
  limit: number;
}
