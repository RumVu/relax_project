/**
 * Shared types for the AI Insights module.
 *
 * Providers (Gemini, deterministic fallback) produce an InsightDraft list
 * + a RecommendationDraft list. AiInsightsService persists them to the
 * AIInsight and Recommendation Prisma tables.
 */

import type { MoodType } from '@prisma/client';

export interface MoodAggregate {
  /** Total mood check-ins inside the analysis window. */
  total: number;
  /** Dominant mood by count. */
  topMood: MoodType | null;
  /** Mean of finalScore (0..100) across the window. */
  averageScore: number;
  /** Count per mood — for prompting and audit. */
  breakdown: Array<{ mood: MoodType; count: number }>;
  /** ISO start/end of the window. */
  windowStartIso: string;
  windowEndIso: string;
}

export interface InsightDraft {
  /** Stable key for grouping in UI: 'weekly-summary' | 'mood-pattern' | 'recommendation' | ... */
  type: string;
  title: string;
  content: string;
}

export interface RecommendationDraft {
  /** Prisma model name: 'BreathingExercise' | 'AmbientSound' | 'RelaxActivity' | ... */
  contentType: string;
  contentId: string;
  reason: string;
  score: number; // 0..1
}

export interface InsightGenerationResult {
  provider: string; // 'gemini' | 'deterministic'
  insights: InsightDraft[];
  recommendations: RecommendationDraft[];
}

export interface InsightProviderContext {
  userId: string;
  displayName?: string | null;
  aggregate: MoodAggregate;
  /** Catalog snippet the provider can pick recommendations from. */
  catalog: {
    breathing: Array<{ id: string; title: string; description?: string | null }>;
    ambient: Array<{ id: string; title: string; category?: string | null }>;
  };
}

export interface InsightProvider {
  readonly name: string;
  generate(ctx: InsightProviderContext): Promise<InsightGenerationResult>;
}
