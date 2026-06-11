import { Injectable, OnModuleInit } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AchievementType } from '@prisma/client';
import { FeedService } from '../feed/feed.service';

@Injectable()
export class AchievementsService implements OnModuleInit {
  constructor(
    private readonly prisma: PrismaService,
    private readonly feedService: FeedService,
  ) {}

  async onModuleInit() {
    const defaultAchievements = [
      {
        title: 'Bước đầu ghi nhận cảm xúc',
        description: 'Ghi chép cảm xúc đầu tiên của bạn.',
        type: AchievementType.CONSISTENCY,
        points: 10,
        condition: {},
      },
      {
        title: 'Buổi thư giãn đầu tiên',
        description: 'Hoàn thành buổi thư giãn đầu tiên của bạn.',
        type: AchievementType.WELLNESS,
        points: 10,
        condition: {},
      },
      {
        title: 'Nhiệm vụ đầu tiên',
        description: 'Hoàn thành nhiệm vụ ngày đầu tiên của bạn.',
        type: AchievementType.EXPLORATION,
        points: 10,
        condition: {},
      },
      {
        title: 'Chuỗi 3 ngày: Đồng hành chớm nở',
        description: 'Ghi nhận cảm xúc liên tục trong 3 ngày.',
        type: AchievementType.CONSISTENCY,
        points: 30,
        condition: {},
      },
      {
        title: 'Chuỗi 7 ngày: Thói quen vững vàng',
        description: 'Ghi nhận cảm xúc liên tục trong 7 ngày.',
        type: AchievementType.CONSISTENCY,
        points: 50,
        condition: {},
      },
      {
        title: 'Chuỗi 30 ngày: Bậc thầy tự cân bằng',
        description: 'Ghi nhận cảm xúc liên tục trong 30 ngày.',
        type: AchievementType.CONSISTENCY,
        points: 100,
        condition: {},
      },
    ];

    for (const a of defaultAchievements) {
      const existing = await this.prisma.achievement.findFirst({
        where: { title: a.title },
      });
      if (!existing) {
        await this.prisma.achievement.create({ data: a });
      }
    }
  }

  async listMe(userId: string) {
    const all = await this.prisma.achievement.findMany({
      where: { isActive: true },
    });
    const unlocked = await this.prisma.userAchievement.findMany({
      where: { userId },
      select: { achievementId: true, unlockedAt: true },
    });
    const unlockedIds = new Set(unlocked.map((u) => u.achievementId));

    return all.map((a) => ({
      ...a,
      unlocked: unlockedIds.has(a.id),
      unlockedAt:
        unlocked.find((u) => u.achievementId === a.id)?.unlockedAt ?? null,
      description: a.description ?? '', // Ensure fallback
    }));
  }

  async checkAndUnlock(userId: string, title: string) {
    const achievement = await this.prisma.achievement.findFirst({
      where: { title, isActive: true },
    });
    if (!achievement) return;

    const existingUnlock = await this.prisma.userAchievement.findUnique({
      where: {
        userId_achievementId: {
          userId,
          achievementId: achievement.id,
        },
      },
    });

    if (!existingUnlock) {
      await this.prisma.userAchievement.create({
        data: {
          userId,
          achievementId: achievement.id,
        },
      });

      const userPoints = await this.prisma.userPoints.upsert({
        where: { userId },
        update: { totalPoints: { increment: achievement.points } },
        create: { userId, totalPoints: achievement.points },
      });

      await this.prisma.pointsTransaction.create({
        data: {
          userPointsId: userPoints.id,
          amount: achievement.points,
          reason: `Mở khóa thành tựu: ${achievement.title}`,
        },
      });

      try {
        await this.feedService.createEntry(
          userId,
          'ACHIEVEMENT_UNLOCKED',
          'Đã mở khóa thành tựu mới',
          `đã đạt thành tựu: "${achievement.title}" - ${achievement.description ?? ''}`,
          achievement.id,
        );
      } catch {
        // Do not block unlock logic if feed entry fails
      }
    }
  }
}
