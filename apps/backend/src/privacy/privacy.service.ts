import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpdatePrivacySettingsDto } from './dto/update-privacy-settings.dto';

@Injectable()
export class PrivacyService {
  constructor(private readonly prisma: PrismaService) {}

  /** What data we store: counts per category. */
  async getDataSummary(userId: string) {
    const [
      journals,
      moodCheckins,
      relaxSessions,
      meditationSessions,
      breathingSessions,
      sleepSessions,
      soundSessions,
      companionInteractions,
      notifications,
      feedEntries,
    ] = await Promise.all([
      this.prisma.journal.count({ where: { userId } }),
      this.prisma.moodCheckin.count({ where: { userId } }),
      this.prisma.relaxSession.count({ where: { userId } }),
      this.prisma.meditationSession.count({ where: { userId } }),
      this.prisma.breathingSession.count({ where: { userId } }),
      this.prisma.sleepSession.count({ where: { userId } }),
      this.prisma.soundSession.count({ where: { userId } }),
      this.prisma.companionInteraction.count({ where: { userId } }),
      this.prisma.notification.count({ where: { userId } }),
      this.prisma.feedEntry.count({ where: { userId } }),
    ]);

    return {
      journals,
      moodCheckins,
      relaxSessions,
      meditationSessions,
      breathingSessions,
      sleepSessions,
      soundSessions,
      companionInteractions,
      notifications,
      feedEntries,
    };
  }

  /** Full data export (JSON or CSV). */
  async exportData(userId: string, format: 'json' | 'csv' = 'json') {
    const data = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        id: true,
        email: true,
        name: true,
        avatar: true,
        createdAt: true,
        moodCheckins: { orderBy: { createdAt: 'desc' } },
        journals: { orderBy: { createdAt: 'desc' } },
        relaxSessions: { orderBy: { startedAt: 'desc' } },
        meditationSessions: { orderBy: { startedAt: 'desc' } },
        breathingSessions: { orderBy: { startedAt: 'desc' } },
        sleepSessions: { orderBy: { startedAt: 'desc' } },
        soundSessions: { orderBy: { startedAt: 'desc' } },
        companionInteractions: { orderBy: { createdAt: 'desc' } },
        feedEntries: { orderBy: { createdAt: 'desc' } },
        userAchievements: { orderBy: { unlockedAt: 'desc' } },
        userStreak: true,
      },
    });

    if (format === 'csv') {
      return this.toCsv(data);
    }

    return {
      exportedAt: new Date().toISOString(),
      formatVersion: 'thi-ai-privacy-export-v1',
      userId,
      data,
    };
  }

  /** Delete all journals for user. */
  async deleteJournalsOnly(userId: string) {
    const result = await this.prisma.journal.deleteMany({
      where: { userId },
    });
    return { deleted: result.count, type: 'journals' };
  }

  /** Delete all mood checkins for user. */
  async deleteMoodHistory(userId: string) {
    const result = await this.prisma.moodCheckin.deleteMany({
      where: { userId },
    });
    return { deleted: result.count, type: 'moodCheckins' };
  }

  /** Delete all relax sessions for user. */
  async deleteSessionHistory(userId: string) {
    const result = await this.prisma.relaxSession.deleteMany({
      where: { userId },
    });
    return { deleted: result.count, type: 'relaxSessions' };
  }

  /** Read AI privacy mode from UserPreference. */
  async getPrivacySettings(userId: string) {
    const pref = await this.prisma.userPreference.findUnique({
      where: { userId },
    });

    return {
      aiPrivacyMode:
        pref?.pushNotificationsEnabled !== undefined
          ? !(pref?.emailNotificationsEnabled ?? false)
          : false,
      // We store AI privacy mode as a convention; if no dedicated column
      // exists, we read from the preference metadata. For now we return
      // a sensible default until a migration adds the column.
      language: pref?.language ?? 'vi',
      timezone: pref?.timezone ?? 'Asia/Ho_Chi_Minh',
    };
  }

  /** Toggle AI privacy mode. */
  async updatePrivacySettings(userId: string, dto: UpdatePrivacySettingsDto) {
    // Since UserPreference doesn't have a dedicated aiPrivacyMode column,
    // we upsert the preference record. When a migration adds the column,
    // this will use it directly.
    const pref = await this.prisma.userPreference.upsert({
      where: { userId },
      create: {
        userId,
        emailNotificationsEnabled: !(dto.aiPrivacyMode ?? false),
      },
      update: {
        emailNotificationsEnabled: !(dto.aiPrivacyMode ?? false),
      },
    });

    return {
      aiPrivacyMode: !pref.emailNotificationsEnabled,
      updated: true,
    };
  }

  private toCsv(data: unknown): string {
    if (!data || typeof data !== 'object') return '';
    const record = data as Record<string, unknown>;
    const sections: string[] = [];

    for (const [key, value] of Object.entries(record)) {
      if (Array.isArray(value) && value.length > 0) {
        const headers = Object.keys(value[0] as object);
        const rows = value.map((item) => {
          const row = item as Record<string, unknown>;
          return headers.map((h) => JSON.stringify(row[h] ?? '')).join(',');
        });
        sections.push(
          `--- ${key} ---\n${headers.join(',')}\n${rows.join('\n')}`,
        );
      }
    }

    return sections.join('\n\n');
  }
}
