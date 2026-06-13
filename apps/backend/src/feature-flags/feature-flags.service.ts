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
}
