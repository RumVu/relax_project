/**
 * GDPR-style "export everything I have" for the signed-in user.
 *
 * Returns ONE giant tree of the user's records across every related
 * table. Sensitive fields (password hash, refresh-token hash, account
 * token hash, integration tokens) are intentionally excluded — they
 * have no value to the user and would harm them if leaked.
 */
import { Injectable } from '@nestjs/common';
import { AppException } from '../../common/errors/app.exception';
import { ErrorCode } from '../../common/errors/error-code';
import { PrismaService } from '../../prisma/prisma.service';
import { userSelect } from '../../users/user.select';

const EXPORT_FORMAT_VERSION = 'digital-cigarette-break-user-export-v1';

/** Fields intentionally NOT included in the export. */
const EXCLUDED_FIELDS = [
  'User.password',
  'Session.refreshToken',
  'AccountToken.tokenHash',
  'PushDevice.token',
  'IntegrationLink.accessToken',
  'IntegrationLink.refreshToken',
];

@Injectable()
export class UserExportService {
  constructor(private readonly prisma: PrismaService) {}

  async exportForUser(userId: string) {
    const exportData = await this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        ...userSelect,
        sessions: {
          select: {
            id: true,
            userAgent: true,
            ipAddress: true,
            expiresAt: true,
            createdAt: true,
          },
          orderBy: { createdAt: 'desc' },
        },
        accountTokens: {
          select: {
            id: true,
            type: true,
            expiresAt: true,
            consumedAt: true,
            metadata: true,
            createdAt: true,
          },
          orderBy: { createdAt: 'desc' },
        },
        pushDevices: {
          select: {
            id: true,
            platform: true,
            provider: true,
            deviceId: true,
            deviceName: true,
            appVersion: true,
            timezone: true,
            enabled: true,
            lastSeenAt: true,
            createdAt: true,
            updatedAt: true,
          },
          orderBy: { createdAt: 'desc' },
        },
        companion: {
          include: {
            asset: true,
            states: { orderBy: { startedAt: 'desc' } },
            interactions: { orderBy: { createdAt: 'desc' } },
          },
        },
        companionInteractions: { orderBy: { createdAt: 'desc' } },
        favoriteMessages: { orderBy: { createdAt: 'desc' } },
        messageLogs: { orderBy: { shownAt: 'desc' } },
        moodCheckins: { orderBy: { createdAt: 'desc' } },
        weeklyMoodStats: { orderBy: { weekStart: 'desc' } },
        journals: { orderBy: { createdAt: 'desc' } },
        meditationSessions: { orderBy: { startedAt: 'desc' } },
        relaxSessions: { orderBy: { startedAt: 'desc' } },
        soundSessions: { orderBy: { startedAt: 'desc' } },
        breathingSessions: { orderBy: { startedAt: 'desc' } },
        sleepSessions: { orderBy: { startedAt: 'desc' } },
        reminders: { orderBy: { scheduledAt: 'desc' } },
        notifications: { orderBy: { createdAt: 'desc' } },
        subscriptions: { orderBy: { createdAt: 'desc' } },
        payments: { orderBy: { createdAt: 'desc' } },
        feedbacks: { orderBy: { createdAt: 'desc' } },
        contentRatings: { orderBy: { createdAt: 'desc' } },
        analyticsSnapshots: { orderBy: { date: 'desc' } },
        integrations: {
          select: {
            id: true,
            type: true,
            isActive: true,
            tokenExpiresAt: true,
            createdAt: true,
            updatedAt: true,
          },
          orderBy: { createdAt: 'desc' },
        },
        aiInsights: { orderBy: { createdAt: 'desc' } },
        insightCards: { orderBy: { createdAt: 'desc' } },
        recommendations: { orderBy: { createdAt: 'desc' } },
        userAchievements: { orderBy: { unlockedAt: 'desc' } },
        userBadges: { orderBy: { earnedAt: 'desc' } },
        userStreak: true,
        userPoints: {
          include: {
            pointsHistory: { orderBy: { createdAt: 'desc' } },
          },
        },
        userLevel: true,
        friends: { orderBy: { requestedAt: 'desc' } },
        friendRequestsReceived: { orderBy: { requestedAt: 'desc' } },
        userChallenges: { orderBy: { joinedAt: 'desc' } },
        leaderboardEntries: { orderBy: { updatedAt: 'desc' } },
        feedEntries: { orderBy: { createdAt: 'desc' } },
        storageFiles: { orderBy: { createdAt: 'desc' } },
        appEvents: { orderBy: { createdAt: 'desc' } },
        platformEvents: { orderBy: { createdAt: 'desc' } },
        rateLimitCounters: { orderBy: { resetAt: 'desc' } },
        adminLogs: { orderBy: { createdAt: 'desc' } },
      },
    });

    if (!exportData) {
      throw AppException.notFound(ErrorCode.USER_NOT_FOUND, 'User not found');
    }

    return {
      exportedAt: new Date().toISOString(),
      formatVersion: EXPORT_FORMAT_VERSION,
      userId,
      excludedFields: EXCLUDED_FIELDS,
      data: exportData,
    };
  }
}
