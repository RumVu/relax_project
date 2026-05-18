import { HttpStatus, Injectable } from '@nestjs/common';
import {
  CompanionAction,
  CompanionMood,
  CompanionPersonalizationMode,
  Prisma,
} from '@prisma/client';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { CreateCompanionInteractionDto } from './dto/create-companion-interaction.dto';
import { SwitchCompanionPersonalizationDto } from './dto/switch-companion-personalization.dto';
import { UpsertUserCompanionDto } from './dto/upsert-user-companion.dto';

@Injectable()
export class UserCompanionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
  ) {}

  async getMine(userId: string) {
    await this.usersService.findOne(userId);
    return this.ensureCompanion(userId);
  }

  async upsertMine(userId: string, dto: UpsertUserCompanionDto) {
    await this.usersService.findOne(userId);
    const existing = await this.prisma.userCompanion.findUnique({
      where: { userId },
    });
    const personalizationMode =
      dto.personalizationMode ??
      existing?.personalizationMode ??
      CompanionPersonalizationMode.DEFAULT;
    const asset = await this.resolveAsset(userId, personalizationMode, dto);
    const data = {
      assetId: asset?.id ?? dto.assetId,
      name: dto.name,
      type: dto.type ?? asset?.type,
      personalizationMode,
      mood: dto.mood,
      action: dto.action,
      level: dto.level,
      affection: dto.affection,
      energy: dto.energy,
      lastSeenAt: new Date(),
      lastMoodAt: dto.mood ? new Date() : undefined,
    };

    if (existing) {
      return this.prisma.userCompanion.update({
        where: { userId },
        data,
        include: { asset: true },
      });
    }

    return this.prisma.userCompanion.create({
      data: {
        userId,
        assetId: asset?.id ?? dto.assetId,
        name: dto.name ?? 'Mon Leo',
        type: dto.type ?? asset?.type,
        personalizationMode,
        mood: dto.mood ?? CompanionMood.CHILL,
        action: dto.action ?? CompanionAction.IDLE,
        level: dto.level ?? 1,
        affection: dto.affection ?? 0,
        energy: dto.energy ?? 100,
        lastSeenAt: new Date(),
      },
      include: { asset: true },
    });
  }

  async interact(userId: string, dto: CreateCompanionInteractionDto) {
    const companion = await this.ensureCompanion(userId);
    const affectionGain = this.getAffectionGain(dto.type);
    const energyDelta = this.getEnergyDelta(dto.type);

    const [interaction, updated] = await this.prisma.$transaction([
      this.prisma.companionInteraction.create({
        data: {
          userId,
          companionId: companion.id,
          type: dto.type,
          metadata: dto.metadata as Prisma.InputJsonValue,
        },
      }),
      this.prisma.userCompanion.update({
        where: { id: companion.id },
        data: {
          affection: Math.min(100, companion.affection + affectionGain),
          energy: Math.max(0, Math.min(100, companion.energy + energyDelta)),
          lastSeenAt: new Date(),
          lastFedAt: dto.type === 'FEED' ? new Date() : companion.lastFedAt,
        },
        include: { asset: true },
      }),
    ]);

    return { interaction, companion: updated };
  }

  async getStats(userId: string) {
    const companion = await this.ensureCompanion(userId);
    const [totalInteractions, recentInteractions] = await Promise.all([
      this.prisma.companionInteraction.count({
        where: { companionId: companion.id },
      }),
      this.prisma.companionInteraction.findMany({
        where: { companionId: companion.id },
        orderBy: { createdAt: 'desc' },
        take: 10,
      }),
    ]);

    return {
      companion,
      totalInteractions,
      recentInteractions,
    };
  }

  async getPersonalizationOptions(userId: string) {
    await this.usersService.findOne(userId);
    const profile = await this.prisma.userProfile.findUnique({
      where: { userId },
      select: {
        birthday: true,
        zodiacSign: true,
        chineseZodiac: true,
      },
    });
    const [defaultAssets, zodiacAssets, chineseZodiacAssets] =
      await Promise.all([
        this.prisma.companionAsset.findMany({
          where: { isDefault: true, isActive: true },
          orderBy: { createdAt: 'desc' },
        }),
        this.prisma.companionAsset.findMany({
          where: {
            isActive: true,
            zodiacSign: profile?.zodiacSign ?? undefined,
          },
          orderBy: { createdAt: 'desc' },
        }),
        this.prisma.companionAsset.findMany({
          where: {
            isActive: true,
            chineseZodiac: profile?.chineseZodiac ?? undefined,
          },
          orderBy: { createdAt: 'desc' },
        }),
      ]);

    return {
      profile,
      modes: [
        {
          mode: CompanionPersonalizationMode.DEFAULT,
          label: 'Mặc định',
          available: defaultAssets.length > 0,
          assets: defaultAssets,
        },
        {
          mode: CompanionPersonalizationMode.ZODIAC,
          label: 'Theo cung hoàng đạo',
          key: profile?.zodiacSign ?? null,
          available: Boolean(profile?.zodiacSign) && zodiacAssets.length > 0,
          assets: zodiacAssets,
        },
        {
          mode: CompanionPersonalizationMode.CHINESE_ZODIAC,
          label: 'Theo 12 con giáp',
          key: profile?.chineseZodiac ?? null,
          available:
            Boolean(profile?.chineseZodiac) && chineseZodiacAssets.length > 0,
          assets: chineseZodiacAssets,
        },
        {
          mode: CompanionPersonalizationMode.CUSTOM,
          label: 'Tự chọn linh thú',
          available: true,
          assets: [],
        },
      ],
    };
  }

  async switchPersonalization(
    userId: string,
    dto: SwitchCompanionPersonalizationDto,
  ) {
    const companion = await this.ensureCompanion(userId);

    if (
      dto.personalizationMode === CompanionPersonalizationMode.CUSTOM &&
      !dto.assetId
    ) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        'assetId is required when personalizationMode is CUSTOM',
        HttpStatus.BAD_REQUEST,
      );
    }

    const asset = await this.resolveAsset(userId, dto.personalizationMode, {
      assetId: dto.assetId,
      personalizationMode: dto.personalizationMode,
    });
    const preserveProgress = dto.preserveProgress !== false;
    const resetVisualState = dto.resetVisualState ?? true;
    const updated = await this.prisma.userCompanion.update({
      where: { id: companion.id },
      data: {
        assetId: asset?.id ?? companion.assetId,
        type: asset?.type ?? companion.type,
        personalizationMode: dto.personalizationMode,
        level: preserveProgress ? companion.level : 1,
        affection: preserveProgress ? companion.affection : 0,
        energy: preserveProgress ? companion.energy : 100,
        mood: resetVisualState ? CompanionMood.CHILL : companion.mood,
        action: resetVisualState ? CompanionAction.IDLE : companion.action,
        lastSeenAt: new Date(),
      },
      include: { asset: true },
    });

    return {
      companion: updated,
      transition: {
        fromMode: companion.personalizationMode,
        toMode: dto.personalizationMode,
        fromAssetId: companion.assetId,
        toAssetId: updated.assetId,
        preserveProgress,
        resetVisualState,
        rule: preserveProgress
          ? 'Giữ level/affection/energy khi đổi linh thú.'
          : 'Reset level/affection/energy theo lựa chọn của client.',
      },
    };
  }

  private async ensureCompanion(userId: string) {
    const companion = await this.prisma.userCompanion.findUnique({
      where: { userId },
      include: { asset: true },
    });

    if (companion) {
      return companion;
    }

    return this.upsertMine(userId, {});
  }

  private async resolveAsset(
    userId: string,
    mode: CompanionPersonalizationMode,
    dto: UpsertUserCompanionDto,
  ) {
    if (mode === CompanionPersonalizationMode.CUSTOM && dto.assetId) {
      return this.prisma.companionAsset.findFirst({
        where: { id: dto.assetId, isActive: true },
      });
    }

    if (mode === CompanionPersonalizationMode.ZODIAC) {
      const profile = await this.prisma.userProfile.findUnique({
        where: { userId },
        select: { zodiacSign: true },
      });

      if (profile?.zodiacSign) {
        const asset = await this.prisma.companionAsset.findFirst({
          where: { zodiacSign: profile.zodiacSign, isActive: true },
          orderBy: { createdAt: 'desc' },
        });

        if (asset) return asset;
      }
    }

    if (mode === CompanionPersonalizationMode.CHINESE_ZODIAC) {
      const profile = await this.prisma.userProfile.findUnique({
        where: { userId },
        select: { chineseZodiac: true },
      });

      if (profile?.chineseZodiac) {
        const asset = await this.prisma.companionAsset.findFirst({
          where: { chineseZodiac: profile.chineseZodiac, isActive: true },
          orderBy: { createdAt: 'desc' },
        });

        if (asset) return asset;
      }
    }

    return this.prisma.companionAsset.findFirst({
      where: { isDefault: true, isActive: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  private getAffectionGain(type: string) {
    const normalized = type.toUpperCase();
    if (normalized === 'PET') return 4;
    if (normalized === 'FEED') return 6;
    if (normalized === 'PLAY') return 5;
    if (normalized === 'MOOD_CHECKIN') return 3;
    return 1;
  }

  private getEnergyDelta(type: string) {
    const normalized = type.toUpperCase();
    if (normalized === 'FEED') return 10;
    if (normalized === 'PLAY') return -8;
    if (normalized === 'SLEEP') return 20;
    return 0;
  }
}
