import {
  HttpStatus,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { GoogleGenAI } from '@google/genai';
import { MoodType } from '@prisma/client';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { DeterministicInsightProvider } from './providers/deterministic.provider';
import { GeminiInsightProvider } from './providers/gemini.provider';
import {
  InsightGenerationResult,
  InsightProvider,
  InsightProviderContext,
  MoodAggregate,
} from './ai-insights.types';

/** Skip auto-regen if we already have insights newer than this. */
const FRESH_TTL_MS = 12 * 60 * 60 * 1000; // 12 hours

/** Default window for analysis. */
const DEFAULT_WINDOW_DAYS = 7;

@Injectable()
export class AiInsightsService {
  private readonly logger = new Logger(AiInsightsService.name);
  private readonly deterministic = new DeterministicInsightProvider();
  private readonly geminiProvider: GeminiInsightProvider | null;

  constructor(
    private readonly prisma: PrismaService,
    private readonly configService: ConfigService,
  ) {
    const modelName =
      this.configService.get<string>('GEMINI_MODEL') ?? 'gemini-2.5-flash';

    let ai: GoogleGenAI | null = null;
    const projectId = this.configService.get<string>('VERTEX_PROJECT_ID');
    const apiKey = this.configService.get<string>('GEMINI_API_KEY');
    if (projectId) {
      const location =
        this.configService.get<string>('VERTEX_LOCATION') || 'us-central1';
      ai = new GoogleGenAI({ vertexai: true, project: projectId, location });
    } else if (apiKey) {
      ai = new GoogleGenAI({ apiKey });
    }

    this.geminiProvider = ai ? new GeminiInsightProvider(ai, modelName) : null;
    if (this.geminiProvider) {
      this.logger.log(
        `AiInsightsService: Gemini provider active (model=${modelName})`,
      );
    } else {
      this.logger.log(
        'AiInsightsService: no VERTEX_PROJECT_ID or GEMINI_API_KEY — using deterministic provider only',
      );
    }
  }

  // ============================================================
  // PUBLIC API
  // ============================================================

  /**
   * Return the user's most recent insights + recommendations. Auto-generates
   * a fresh batch when nothing exists, or when the most recent batch is
   * older than FRESH_TTL_MS.
   */
  async getMine(userId: string, limit = 5) {
    const latestInsight = await this.prisma.aIInsight.findFirst({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });

    const stale =
      !latestInsight ||
      Date.now() - latestInsight.createdAt.getTime() > FRESH_TTL_MS;

    if (stale) {
      await this.generateForUser(userId).catch((err: unknown) =>
        this.logger.warn(
          `Auto-generate insights for ${userId} failed: ${
            err instanceof Error ? err.message : String(err)
          }`,
        ),
      );
    }

    return this.readMine(userId, limit);
  }

  async refreshMine(userId: string, limit = 5) {
    await this.generateForUser(userId);
    return this.readMine(userId, limit);
  }

  async setFeedback(userId: string, insightId: string, useful: boolean) {
    const existing = await this.prisma.aIInsight.findUnique({
      where: { id: insightId },
    });
    if (!existing || existing.userId !== userId) {
      throw new NotFoundException({
        code: ErrorCode.DATABASE_RECORD_NOT_FOUND,
        message: 'Insight not found',
      });
    }
    const updated = await this.prisma.aIInsight.update({
      where: { id: insightId },
      data: { isUseful: useful },
    });
    return { success: true, insight: updated };
  }

  // ============================================================
  // INTERNAL
  // ============================================================

  private async readMine(userId: string, limit: number) {
    const insights = await this.prisma.aIInsight.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
    const recommendations = await this.prisma.recommendation.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      take: limit,
    });
    return {
      provider: insights[0]?.aiProvider ?? 'none',
      generatedAt: insights[0]?.createdAt ?? null,
      insights,
      recommendations,
    };
  }

  private async generateForUser(userId: string) {
    const aggregate = await this.aggregateMood(userId, DEFAULT_WINDOW_DAYS);
    const catalog = await this.fetchCatalog();
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, name: true },
    });
    if (!user) {
      throw new AppException(
        ErrorCode.DATABASE_RECORD_NOT_FOUND,
        'User not found',
        HttpStatus.NOT_FOUND,
      );
    }

    const ctx: InsightProviderContext = {
      userId,
      displayName: user.name,
      aggregate,
      catalog,
    };

    const provider = this.pickProvider();
    let result: InsightGenerationResult;
    try {
      result = await provider.generate(ctx);
    } catch (err) {
      const msg = err instanceof Error ? err.message : String(err);
      this.logger.warn(
        `Provider ${provider.name} failed (${msg}); falling back to deterministic`,
      );
      result = await this.deterministic.generate(ctx);
    }

    // Persist atomically — wipe old before writing new so the dashboard
    // never shows a mix of stale + fresh.
    await this.prisma.$transaction([
      this.prisma.aIInsight.deleteMany({ where: { userId } }),
      this.prisma.recommendation.deleteMany({ where: { userId } }),
      this.prisma.aIInsight.createMany({
        data: result.insights.map((i) => ({
          userId,
          type: i.type,
          title: i.title,
          content: i.content,
          aiProvider: result.provider,
        })),
      }),
      this.prisma.recommendation.createMany({
        data: result.recommendations.map((r) => ({
          userId,
          contentType: r.contentType,
          contentId: r.contentId,
          reason: r.reason,
          score: r.score,
        })),
      }),
    ]);

    this.logger.log(
      `Generated ${result.insights.length} insights + ${result.recommendations.length} recommendations for ${userId} via ${result.provider}`,
    );

    return result;
  }

  private pickProvider(): InsightProvider {
    return this.geminiProvider ?? this.deterministic;
  }

  private async aggregateMood(
    userId: string,
    days: number,
  ): Promise<MoodAggregate> {
    const windowEnd = new Date();
    const windowStart = new Date(
      windowEnd.getTime() - days * 24 * 60 * 60 * 1000,
    );

    const rows = await this.prisma.moodCheckin.findMany({
      where: { userId, createdAt: { gte: windowStart, lte: windowEnd } },
      select: { mood: true, finalScore: true },
    });

    const counts = new Map<MoodType, number>();
    let scoreSum = 0;
    let scoreN = 0;
    for (const row of rows) {
      counts.set(row.mood, (counts.get(row.mood) ?? 0) + 1);
      if (typeof row.finalScore === 'number') {
        scoreSum += row.finalScore;
        scoreN += 1;
      }
    }

    let topMood: MoodType | null = null;
    let topCount = 0;
    for (const [mood, count] of counts) {
      if (count > topCount) {
        topMood = mood;
        topCount = count;
      }
    }

    return {
      total: rows.length,
      topMood,
      averageScore: scoreN > 0 ? scoreSum / scoreN : 0,
      breakdown: Array.from(counts.entries()).map(([mood, count]) => ({
        mood,
        count,
      })),
      windowStartIso: windowStart.toISOString(),
      windowEndIso: windowEnd.toISOString(),
    };
  }

  private async fetchCatalog() {
    const [breathing, ambient] = await Promise.all([
      this.prisma.breathingExercise.findMany({
        where: { isActive: true },
        take: 12,
        orderBy: { createdAt: 'desc' },
        select: { id: true, title: true, description: true },
      }),
      this.prisma.ambientSound.findMany({
        where: { isActive: true },
        take: 16,
        orderBy: { createdAt: 'desc' },
        select: { id: true, title: true, category: true },
      }),
    ]);
    return { breathing, ambient };
  }
}
