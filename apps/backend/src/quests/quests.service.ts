import {
  HttpStatus,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { UserQuest } from '@prisma/client';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import {
  pickQuestTemplate,
  QuestMetric,
  QuestScope,
  QuestTemplate,
  QUEST_TEMPLATES,
} from './quest-templates';

/** How many quests a user sees at a time on the dashboard. */
const ACTIVE_QUEST_COUNT = 4;

export type Locale = 'vi' | 'en';

export interface QuestStateView {
  id: string;
  templateCode: string;
  category: QuestTemplate['category'];
  title: string;
  description: string;
  scope: QuestScope;
  target: number;
  progress: number;
  completed: boolean;
  completedAt: string | null;
  assignedAt: string;
}

@Injectable()
export class QuestsService {
  private readonly logger = new Logger(QuestsService.name);
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Read the active quest slate for a user. If they don't have ACTIVE_QUEST_COUNT
   * active rows, fill the deficit with fresh random templates.
   */
  async getMine(
    userId: string,
    locale: Locale = 'vi',
  ): Promise<QuestStateView[]> {
    await this.ensureActive(userId);
    const rows = await this.prisma.userQuest.findMany({
      where: { userId },
      orderBy: { assignedAt: 'asc' },
    });

    // Re-evaluate every row each call. Cheap (one query per metric), keeps
    // the UI honest without us needing webhooks from every other service.
    const views = await Promise.all(
      rows.map((row) => this.evaluate(row, locale)),
    );

    // Persist `completedAt` for any rows that crossed the threshold during
    // this read so subsequent reads can short-circuit.
    const newlyCompleted = views.filter(
      (v, i) => v.completed && !rows[i].completedAt,
    );
    if (newlyCompleted.length > 0) {
      await this.prisma.userQuest.updateMany({
        where: { id: { in: newlyCompleted.map((v) => v.id) } },
        data: { completedAt: new Date() },
      });
    }
    return views;
  }

  /**
   * Replace one of the user's active quests with a different random template.
   * The new template is one not currently assigned to the user.
   */
  async reroll(userId: string, questId: string, locale: Locale = 'vi') {
    const existing = await this.prisma.userQuest.findUnique({
      where: { id: questId },
    });
    if (!existing || existing.userId !== userId) {
      throw new NotFoundException({
        code: ErrorCode.DATABASE_RECORD_NOT_FOUND,
        message: `Quest ${questId} not found`,
      });
    }
    const taken = await this.prisma.userQuest.findMany({
      where: { userId },
      select: { templateCode: true },
    });
    const takenSet = new Set(taken.map((t) => t.templateCode));
    const candidates = QUEST_TEMPLATES.filter(
      (t) => t.code !== existing.templateCode && !takenSet.has(t.code),
    );
    if (candidates.length === 0) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        'No more quest templates available to reroll into.',
        HttpStatus.BAD_REQUEST,
      );
    }
    const next = candidates[Math.floor(Math.random() * candidates.length)];

    const updated = await this.prisma.userQuest.update({
      where: { id: questId },
      data: {
        templateCode: next.code,
        assignedAt: new Date(),
        completedAt: null,
      },
    });
    this.logger.log(
      `Quest reroll for ${userId}: ${existing.templateCode} → ${next.code}`,
    );
    return this.evaluate(updated, locale);
  }

  // ============================================================
  // INTERNAL
  // ============================================================

  private async ensureActive(userId: string) {
    const rows = await this.prisma.userQuest.findMany({
      where: { userId },
      select: { id: true, templateCode: true },
    });
    if (rows.length >= ACTIVE_QUEST_COUNT) return;

    const taken = new Set(rows.map((r) => r.templateCode));
    const pool = QUEST_TEMPLATES.filter((t) => !taken.has(t.code));
    const need = ACTIVE_QUEST_COUNT - rows.length;
    const fresh = this.shuffle(pool).slice(0, need);

    if (fresh.length === 0) return;
    await this.prisma.userQuest.createMany({
      data: fresh.map((t) => ({ userId, templateCode: t.code })),
    });
    this.logger.log(
      `Seeded ${fresh.length} quests for ${userId}: ${fresh.map((f) => f.code).join(', ')}`,
    );
  }

  private async evaluate(
    row: UserQuest,
    locale: Locale,
  ): Promise<QuestStateView> {
    const tmpl = pickQuestTemplate(row.templateCode);
    if (!tmpl) {
      // Orphaned row pointing at a deleted template — surface a sentinel
      // entry so the UI can still show + reroll it.
      return {
        id: row.id,
        templateCode: row.templateCode,
        category: 'journal',
        title: row.templateCode,
        description: '(missing template)',
        scope: 'today',
        target: 1,
        progress: 0,
        completed: Boolean(row.completedAt),
        completedAt: row.completedAt?.toISOString() ?? null,
        assignedAt: row.assignedAt.toISOString(),
      };
    }

    const since = this.windowStart(tmpl.scope, row.assignedAt);
    const progress = await this.measure(row.userId, tmpl.metric, since);
    const completed = progress >= tmpl.target;
    return {
      id: row.id,
      templateCode: tmpl.code,
      category: tmpl.category,
      title: tmpl.title[locale],
      description: tmpl.description[locale],
      scope: tmpl.scope,
      target: tmpl.target,
      progress: Math.min(progress, tmpl.target),
      completed,
      completedAt:
        row.completedAt?.toISOString() ??
        (completed ? new Date().toISOString() : null),
      assignedAt: row.assignedAt.toISOString(),
    };
  }

  private windowStart(scope: QuestScope, assignedAt: Date): Date {
    const now = new Date();
    switch (scope) {
      case 'today': {
        // Start of today (local server time — close enough for daily quests).
        const d = new Date(now);
        d.setHours(0, 0, 0, 0);
        // Don't count actions that happened before the quest was assigned —
        // otherwise a user who already journaled would "auto-complete" the
        // moment they got the quest.
        return assignedAt > d ? assignedAt : d;
      }
      case 'week': {
        const d = new Date(now);
        d.setDate(d.getDate() - 7);
        return assignedAt > d ? assignedAt : d;
      }
      case 'all-time':
        return assignedAt;
    }
  }

  private async measure(
    userId: string,
    metric: QuestMetric,
    since: Date,
  ): Promise<number> {
    switch (metric) {
      case 'journal_entries':
        return this.prisma.journal.count({
          where: { userId, createdAt: { gte: since } },
        });
      case 'mood_checkins':
        return this.prisma.moodCheckin.count({
          where: { userId, createdAt: { gte: since } },
        });
      case 'breathing_sessions':
        return this.prisma.breathingSession.count({
          where: { userId, startedAt: { gte: since } },
        });
      case 'relax_sessions':
        return this.prisma.relaxSession.count({
          where: { userId, createdAt: { gte: since } },
        });
      case 'companion_interactions':
        return this.prisma.companionInteraction.count({
          where: { userId, createdAt: { gte: since } },
        });
      case 'favorite_journals':
        return this.prisma.journal.count({
          where: { userId, isFavorite: true, updatedAt: { gte: since } },
        });
      case 'distinct_mood_types': {
        const rows = await this.prisma.moodCheckin.findMany({
          where: { userId, createdAt: { gte: since } },
          select: { mood: true },
          distinct: ['mood'],
        });
        return rows.length;
      }
      case 'distinct_journal_tags': {
        const rows = await this.prisma.journal.findMany({
          where: { userId, createdAt: { gte: since } },
          select: { tags: true },
        });
        const set = new Set<string>();
        for (const r of rows) {
          for (const tag of r.tags) {
            const cleaned = tag.trim();
            if (cleaned) set.add(cleaned.toLowerCase());
          }
        }
        return set.size;
      }
      case 'sound_minutes': {
        const rows = await this.prisma.soundSession.findMany({
          where: { userId, startedAt: { gte: since } },
          select: { duration: true },
        });
        const totalSeconds = rows.reduce(
          (sum, r) => sum + (r.duration ?? 0),
          0,
        );
        return Math.floor(totalSeconds / 60);
      }
    }
  }

  private shuffle<T>(arr: T[]): T[] {
    const copy = arr.slice();
    for (let i = copy.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      [copy[i], copy[j]] = [copy[j], copy[i]];
    }
    return copy;
  }
}
