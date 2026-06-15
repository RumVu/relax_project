import { Injectable, NotFoundException } from '@nestjs/common';
import { MoodGoalStatus, MoodType } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMoodGoalDto } from './dto/create-mood-goal.dto';
import { UpdateMoodGoalDto } from './dto/update-mood-goal.dto';

@Injectable()
export class MoodGoalsService {
  constructor(private readonly prisma: PrismaService) {}

  async create(userId: string, dto: CreateMoodGoalDto) {
    return this.prisma.moodGoal.create({
      data: {
        userId,
        title: dto.title,
        description: dto.description,
        type: dto.type,
        targetMood: dto.targetMood,
        targetCount: dto.targetCount,
        targetDays: dto.targetDays,
        endDate: dto.endDate ? new Date(dto.endDate) : undefined,
        milestones: dto.milestones
          ? {
              create: dto.milestones.map((m) => ({
                title: m.title,
                target: m.target,
              })),
            }
          : undefined,
      },
      include: { milestones: true },
    });
  }

  async findByUser(userId: string, status?: MoodGoalStatus) {
    return this.prisma.moodGoal.findMany({
      where: { userId, ...(status ? { status } : {}) },
      include: { milestones: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string, userId: string) {
    const goal = await this.prisma.moodGoal.findFirst({
      where: { id, userId },
      include: { milestones: true },
    });
    if (!goal) throw new NotFoundException('Goal not found');
    return goal;
  }

  async update(id: string, userId: string, dto: UpdateMoodGoalDto) {
    await this.findOne(id, userId);
    return this.prisma.moodGoal.update({
      where: { id },
      data: {
        ...dto,
        endDate: dto.endDate ? new Date(dto.endDate) : undefined,
        completedAt:
          dto.status === MoodGoalStatus.COMPLETED ? new Date() : undefined,
      },
      include: { milestones: true },
    });
  }

  async remove(id: string, userId: string) {
    await this.findOne(id, userId);
    return this.prisma.moodGoal.delete({ where: { id } });
  }

  async getProgress(userId: string) {
    const active = await this.prisma.moodGoal.findMany({
      where: { userId, status: MoodGoalStatus.ACTIVE },
      include: { milestones: true },
    });

    return Promise.all(
      active.map(async (goal) => {
        const progress = await this.calculateProgress(userId, goal);
        return { ...goal, progress };
      }),
    );
  }

  async getSummary(userId: string) {
    const [active, completed, total] = await Promise.all([
      this.prisma.moodGoal.count({
        where: { userId, status: MoodGoalStatus.ACTIVE },
      }),
      this.prisma.moodGoal.count({
        where: { userId, status: MoodGoalStatus.COMPLETED },
      }),
      this.prisma.moodGoal.count({ where: { userId } }),
    ]);

    return { active, completed, total, completionRate: total > 0 ? completed / total : 0 };
  }

  async onMoodCheckin(userId: string, mood: MoodType) {
    const activeGoals = await this.prisma.moodGoal.findMany({
      where: { userId, status: MoodGoalStatus.ACTIVE },
      include: { milestones: true },
    });

    const updates: Promise<unknown>[] = [];

    for (const goal of activeGoals) {
      let shouldIncrement = false;

      switch (goal.type) {
        case 'TARGET_MOOD':
          shouldIncrement = goal.targetMood === mood;
          break;
        case 'REDUCE_MOOD':
          shouldIncrement = goal.targetMood !== mood;
          break;
        case 'CHECKIN_COUNT':
        case 'STREAK':
          shouldIncrement = true;
          break;
      }

      if (shouldIncrement) {
        const newCount = goal.currentCount + 1;
        const isCompleted =
          goal.targetCount != null && newCount >= goal.targetCount;

        updates.push(
          this.prisma.moodGoal.update({
            where: { id: goal.id },
            data: {
              currentCount: newCount,
              status: isCompleted ? MoodGoalStatus.COMPLETED : undefined,
              completedAt: isCompleted ? new Date() : undefined,
            },
          }),
        );

        for (const ms of goal.milestones) {
          if (!ms.reached && newCount >= ms.target) {
            updates.push(
              this.prisma.moodGoalMilestone.update({
                where: { id: ms.id },
                data: { reached: true, reachedAt: new Date() },
              }),
            );
          }
        }
      }
    }

    await Promise.all(updates);
  }

  private async calculateProgress(
    userId: string,
    goal: { type: string; targetMood: MoodType | null; targetCount: number | null; currentCount: number; startDate: Date },
  ) {
    const since = goal.startDate;

    if (goal.type === 'TARGET_MOOD' && goal.targetMood) {
      const count = await this.prisma.moodCheckin.count({
        where: { userId, mood: goal.targetMood, createdAt: { gte: since } },
      });
      return {
        current: count,
        target: goal.targetCount ?? 0,
        percentage: goal.targetCount ? Math.min(100, Math.round((count / goal.targetCount) * 100)) : 0,
      };
    }

    if (goal.type === 'CHECKIN_COUNT') {
      const count = await this.prisma.moodCheckin.count({
        where: { userId, createdAt: { gte: since } },
      });
      return {
        current: count,
        target: goal.targetCount ?? 0,
        percentage: goal.targetCount ? Math.min(100, Math.round((count / goal.targetCount) * 100)) : 0,
      };
    }

    return {
      current: goal.currentCount,
      target: goal.targetCount ?? 0,
      percentage: goal.targetCount
        ? Math.min(100, Math.round((goal.currentCount / goal.targetCount) * 100))
        : 0,
    };
  }
}
