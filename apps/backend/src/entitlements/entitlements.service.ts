import { Injectable } from '@nestjs/common';
import { SubscriptionStatus, UserRole } from '@prisma/client';
import { PrismaService } from '../prisma/prisma.service';

export interface FeatureAccess {
  key: string;
  label: string;
  free: boolean;
  premium: boolean;
}

const FEATURE_MAP: FeatureAccess[] = [
  { key: 'mood_checkin', label: 'Check-in cảm xúc', free: true, premium: true },
  { key: 'breathing', label: 'Bài tập thở cơ bản', free: true, premium: true },
  { key: 'journal', label: 'Nhật ký tinh thần', free: true, premium: true },
  { key: 'companion', label: 'Companion cơ bản', free: true, premium: true },
  { key: 'calm_now', label: 'Dịu lại ngay', free: true, premium: true },
  { key: 'mood_calendar', label: 'Lịch cảm xúc', free: true, premium: true },
  { key: 'voice_checkin', label: 'Check-in giọng nói', free: false, premium: true },
  { key: 'mood_forecast', label: 'Dự báo cảm xúc', free: false, premium: true },
  { key: 'mood_recovery', label: 'Phân tích hồi phục', free: false, premium: true },
  { key: 'wellness_report', label: 'Báo cáo PDF', free: false, premium: true },
  { key: 'advanced_breathing', label: 'Bài tập thở nâng cao', free: false, premium: true },
  { key: 'meditation', label: 'Thiền định có hướng dẫn', free: false, premium: true },
  { key: 'soundscape', label: 'Soundscape tuỳ chỉnh', free: false, premium: true },
  { key: 'routine_builder', label: 'Routine Builder 2.0', free: false, premium: true },
  { key: 'ai_insights', label: 'AI Insights', free: false, premium: true },
  { key: 'notification_lab', label: 'Notification Lab', free: false, premium: true },
];

@Injectable()
export class EntitlementsService {
  constructor(private readonly prisma: PrismaService) {}

  async getUserEntitlements(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { role: true },
    });

    const isAdmin = user?.role === UserRole.ADMIN;

    const activeSub = await this.prisma.subscription.findFirst({
      where: {
        userId,
        status: SubscriptionStatus.ACTIVE,
      },
      select: {
        id: true,
        plan: true,
        status: true,
        startDate: true,
        endDate: true,
      },
    });

    const isPremium = isAdmin || !!activeSub;
    const plan = isAdmin ? 'ADMIN' : activeSub ? 'PREMIUM' : 'FREE';

    const features = FEATURE_MAP.map((f) => ({
      ...f,
      unlocked: isPremium ? f.premium : f.free,
    }));

    const unlockedCount = features.filter((f) => f.unlocked).length;

    return {
      userId,
      plan,
      isPremium,
      subscription: activeSub,
      features,
      summary: {
        total: features.length,
        unlocked: unlockedCount,
        locked: features.length - unlockedCount,
      },
    };
  }

  getFeatureMap() {
    return FEATURE_MAP;
  }
}
