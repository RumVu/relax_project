import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UpsertFeatureFlagDto } from './dto/upsert-feature-flag.dto';

@Injectable()
export class FeatureFlagsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll() {
    const items = await this.prisma.featureFlag.findMany({
      orderBy: { createdAt: 'desc' },
    });
    return { items, total: items.length };
  }

  async findByKey(key: string) {
    return this.prisma.featureFlag.findUnique({ where: { key } });
  }

  async isEnabled(key: string): Promise<boolean> {
    const flag = await this.prisma.featureFlag.findUnique({ where: { key } });
    return flag?.enabled ?? false;
  }

  async upsert(dto: UpsertFeatureFlagDto) {
    return this.prisma.featureFlag.upsert({
      where: { key: dto.key },
      update: {
        label: dto.label,
        description: dto.description,
        enabled: dto.enabled,
      },
      create: {
        key: dto.key,
        label: dto.label,
        description: dto.description,
        enabled: dto.enabled,
      },
    });
  }

  async toggle(key: string) {
    const flag = await this.prisma.featureFlag.findUnique({ where: { key } });
    if (!flag) return null;
    return this.prisma.featureFlag.update({
      where: { key },
      data: { enabled: !flag.enabled },
    });
  }

  async delete(key: string) {
    return this.prisma.featureFlag.delete({ where: { key } });
  }

  async seedDefaults() {
    const defaults = [
      {
        key: 'ai_companion',
        label: 'AI Companion',
        description: 'Bật/tắt trợ lý AI',
        enabled: true,
      },
      {
        key: 'billing',
        label: 'Billing & Premium',
        description: 'Bật/tắt hệ thống thanh toán',
        enabled: true,
      },
      {
        key: 'social_feed',
        label: 'Social Feed',
        description: 'Feed cộng đồng (chưa public)',
        enabled: false,
      },
      {
        key: 'crisis_safety',
        label: 'Crisis Safety',
        description: 'Lớp an toàn khẩn cấp',
        enabled: true,
      },
      {
        key: 'sound_mixer',
        label: 'Sound Mixer',
        description: 'Trộn âm thanh đa kênh (experimental)',
        enabled: false,
      },
      {
        key: 'demo_mode',
        label: 'Demo Mode',
        description: 'Cho phép đăng nhập demo',
        enabled: true,
      },
      {
        key: 'recommendations',
        label: 'Smart Recommendations',
        description: 'Gợi ý thông minh dựa trên mood',
        enabled: true,
      },
      {
        key: 'trigger_tracking',
        label: 'Trigger Tracking',
        description: 'Theo dõi nguyên nhân stress',
        enabled: true,
      },
      {
        key: 'experiments',
        label: 'A/B Experiments',
        description: 'Hệ thống thí nghiệm A/B',
        enabled: false,
      },
      {
        key: 'weather',
        label: 'Weather Integration',
        description: 'Tích hợp thời tiết',
        enabled: true,
      },
    ];

    const results: any[] = [];
    for (const flag of defaults) {
      const existing = await this.prisma.featureFlag.findUnique({
        where: { key: flag.key },
      });
      if (!existing) {
        results.push(await this.prisma.featureFlag.create({ data: flag }));
      }
    }
    return { seeded: results.length, total: defaults.length };
  }
}
