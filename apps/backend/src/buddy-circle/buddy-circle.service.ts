import { Injectable, BadRequestException } from '@nestjs/common';
import { FriendRequestStatus } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { StartGroupChallengeDto } from './dto/start-group-challenge.dto';

@Injectable()
export class BuddyCircleService {
  constructor(private readonly prisma: PrismaService) {}

  /** Get user's circle members (accepted friends, limit 5). */
  async getMyCircle(userId: string) {
    const friendships = await this.prisma.friend.findMany({
      where: {
        OR: [
          { userId, status: FriendRequestStatus.ACCEPTED },
          { friendId: userId, status: FriendRequestStatus.ACCEPTED },
        ],
      },
      take: 5,
      include: {
        user: {
          select: { id: true, email: true, name: true, avatar: true },
        },
        friend: {
          select: { id: true, email: true, name: true, avatar: true },
        },
      },
    });

    return friendships.map((f) => (f.userId === userId ? f.friend : f.user));
  }

  /** Send a calm nudge notification to a friend. */
  async sendNudge(userId: string, targetUserId: string) {
    // Verify they are actually friends
    const friendship = await this.prisma.friend.findFirst({
      where: {
        OR: [
          { userId, friendId: targetUserId },
          { userId: targetUserId, friendId: userId },
        ],
        status: FriendRequestStatus.ACCEPTED,
      },
    });

    if (!friendship) {
      throw new BadRequestException(
        'Bạn chỉ có thể gửi nhắc nhẹ cho bạn bè đã kết nối',
      );
    }

    const sender = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { name: true, email: true },
    });

    const senderName = sender?.name ?? sender?.email?.split('@')[0] ?? 'Bạn bè';

    await this.prisma.notification.create({
      data: {
        userId: targetUserId,
        title: 'Nhắc nhẹ từ ' + senderName + ' 💜',
        message: 'Bạn ơi, nghỉ ngơi một chút đi 💜',
        type: 'IN_APP',
      },
    });

    return { success: true, message: 'Đã gửi nhắc nhẹ!' };
  }

  /** Get feed entries from circle members (PUBLIC, achievements/milestones only). */
  async getCircleFeed(userId: string) {
    const members = await this.getMyCircle(userId);
    const memberIds = members.map((m) => m.id);
    const userIds = [userId, ...memberIds];

    return this.prisma.feedEntry.findMany({
      where: {
        userId: { in: userIds },
        visibility: 'PUBLIC',
        type: { in: ['ACHIEVEMENT', 'MILESTONE', 'STREAK', 'CHALLENGE'] },
      },
      orderBy: { createdAt: 'desc' },
      take: 50,
      include: {
        user: {
          select: { id: true, name: true, avatar: true },
        },
      },
    });
  }

  /** Start a group challenge and auto-join circle members. */
  async startGroupChallenge(userId: string, dto: StartGroupChallengeDto) {
    const members = await this.getMyCircle(userId);
    const now = new Date();
    const endDate = new Date(now);
    endDate.setDate(endDate.getDate() + dto.durationDays);

    const challenge = await this.prisma.challenge.create({
      data: {
        title: dto.title,
        description: dto.description,
        type: 'GROUP',
        difficulty: 'MEDIUM',
        durationDays: dto.durationDays,
        goal: dto.goal,
        reward: dto.goal * 10,
        createdBy: userId,
        startDate: now,
        endDate,
        isActive: true,
      },
    });

    // Auto-join creator + circle members
    const allUserIds = [userId, ...members.map((m) => m.id)];
    await this.prisma.userChallenge.createMany({
      data: allUserIds.map((uid) => ({
        userId: uid,
        challengeId: challenge.id,
      })),
      skipDuplicates: true,
    });

    return {
      challenge,
      participants: allUserIds.length,
    };
  }

  /** Share mood to buddy circle feed. */
  async shareMood(userId: string) {
    const latestCheckin = await this.prisma.moodCheckin.findFirst({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });

    if (!latestCheckin) {
      throw new BadRequestException('Chưa có mood check-in nào để chia sẻ');
    }

    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { name: true, email: true },
    });
    const displayName = user?.name ?? user?.email?.split('@')[0] ?? 'Bạn';

    const entry = await this.prisma.feedEntry.create({
      data: {
        userId,
        type: 'MOOD_SHARE',
        visibility: 'PUBLIC',
        title: `${displayName} đang cảm thấy ${latestCheckin.mood.toLowerCase()}`,
        content: latestCheckin.note ?? '',
        metadata: {
          mood: latestCheckin.mood,
          score: latestCheckin.finalScore ?? latestCheckin.rawScore,
          intensity: latestCheckin.intensity,
          checkinId: latestCheckin.id,
        },
      },
      include: {
        user: { select: { id: true, name: true, avatar: true } },
      },
    });

    return entry;
  }

  /** React to a feed entry (emoji reaction). */
  async reactToFeed(userId: string, feedEntryId: string, emoji: string) {
    const entry = await this.prisma.feedEntry.findUnique({
      where: { id: feedEntryId },
    });
    if (!entry) {
      throw new BadRequestException('Không tìm thấy bài viết');
    }

    const existing = (entry.metadata as Record<string, unknown>)?.reactions;
    const reactions =
      existing && typeof existing === 'object'
        ? { ...(existing as Record<string, string[]>) }
        : {};

    if (!reactions[emoji]) reactions[emoji] = [];
    if (!reactions[emoji].includes(userId)) {
      reactions[emoji].push(userId);
    }

    await this.prisma.feedEntry.update({
      where: { id: feedEntryId },
      data: {
        metadata: {
          ...(entry.metadata as Record<string, unknown>),
          reactions,
        },
      },
    });

    return { success: true, reactions };
  }

  /** Report a feed entry or user for abusive content. */
  async reportContent(
    userId: string,
    data: { targetUserId?: string; feedEntryId?: string; reason: string },
  ) {
    if (!data.targetUserId && !data.feedEntryId) {
      throw new BadRequestException(
        'Cần chỉ định user hoặc bài viết để báo cáo',
      );
    }

    await this.prisma.notification.create({
      data: {
        userId: 'ADMIN',
        title: 'Content Report',
        message: JSON.stringify({
          reporterId: userId,
          targetUserId: data.targetUserId,
          feedEntryId: data.feedEntryId,
          reason: data.reason,
          createdAt: new Date().toISOString(),
        }),
        type: 'IN_APP',
      },
    });

    if (data.feedEntryId) {
      await this.prisma.feedEntry.update({
        where: { id: data.feedEntryId },
        data: {
          metadata: {
            ...(((
              await this.prisma.feedEntry.findUnique({
                where: { id: data.feedEntryId },
              })
            )?.metadata as Record<string, unknown>) ?? {}),
            reported: true,
            reportedBy: userId,
          },
        },
      });
    }

    return {
      success: true,
      message: 'Báo cáo đã được ghi nhận. Chúng tôi sẽ xem xét.',
    };
  }

  /** Block a user — removes friendship and hides from feed. */
  async blockUser(userId: string, targetUserId: string) {
    if (userId === targetUserId) {
      throw new BadRequestException('Không thể tự block chính mình');
    }

    await this.prisma.friend.deleteMany({
      where: {
        OR: [
          { userId, friendId: targetUserId },
          { userId: targetUserId, friendId: userId },
        ],
      },
    });

    await this.prisma.notification.create({
      data: {
        userId: 'ADMIN',
        title: 'User Blocked',
        message: JSON.stringify({
          blockerId: userId,
          blockedId: targetUserId,
          createdAt: new Date().toISOString(),
        }),
        type: 'IN_APP',
      },
    });

    return { success: true, message: 'Đã chặn người dùng' };
  }

  /** Get circle stats: each member's streak and session count this week. */
  async getCircleStats(userId: string) {
    const members = await this.getMyCircle(userId);
    const allIds = [userId, ...members.map((m) => m.id)];

    const now = new Date();
    const weekStart = new Date(now);
    weekStart.setDate(weekStart.getDate() - weekStart.getDay());
    weekStart.setHours(0, 0, 0, 0);

    const [streaks, sessionCounts] = await Promise.all([
      this.prisma.userStreak.findMany({
        where: { userId: { in: allIds } },
        select: {
          userId: true,
          currentStreak: true,
          longestStreak: true,
        },
      }),
      this.prisma.relaxSession.groupBy({
        by: ['userId'],
        where: {
          userId: { in: allIds },
          startedAt: { gte: weekStart },
        },
        _count: { id: true },
      }),
    ]);

    const streakMap = new Map(streaks.map((s) => [s.userId, s]));
    const sessionMap = new Map(
      sessionCounts.map((s) => [s.userId, s._count.id]),
    );

    // Fetch user info for all members including self
    const users = await this.prisma.user.findMany({
      where: { id: { in: allIds } },
      select: { id: true, name: true, avatar: true, email: true },
    });

    return users.map((u) => ({
      user: u,
      currentStreak: streakMap.get(u.id)?.currentStreak ?? 0,
      longestStreak: streakMap.get(u.id)?.longestStreak ?? 0,
      sessionsThisWeek: sessionMap.get(u.id) ?? 0,
    }));
  }
}
