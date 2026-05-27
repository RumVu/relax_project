import { Injectable } from '@nestjs/common';
import { CompanionType, Prisma } from '@prisma/client';
import { CatalogQueryDto } from '../common/dto/catalog-query.dto';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { buildPage } from '../common/pagination/page';
import { PrismaService } from '../prisma/prisma.service';
import { CreateCompanionAssetDto } from './dto/create-companion-asset.dto';
import { UpdateCompanionAssetDto } from './dto/update-companion-asset.dto';

@Injectable()
export class CompanionAssetsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(query: CatalogQueryDto = {}) {
    const where = this.buildWhere(query);
    const [items, total] = await Promise.all([
      this.prisma.companionAsset.findMany({
        where,
        orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
        skip: query.skip,
        take: query.limit,
      }),
      this.prisma.companionAsset.count({ where }),
    ]);

    return buildPage(items, total, query);
  }

  async findDefault() {
    const asset = await this.prisma.companionAsset.findFirst({
      where: { isDefault: true, isActive: true },
      orderBy: { createdAt: 'desc' },
    });

    if (!asset) {
      throw AppException.notFound(
        ErrorCode.CATALOG_DEFAULT_COMPANION_ASSET_NOT_FOUND,
        'Default companion asset not found',
      );
    }

    return asset;
  }

  async create(dto: CreateCompanionAssetDto) {
    return this.prisma.$transaction(async (tx) => {
      const data = {
        ...dto,
        isActive: dto.isDefault ? true : dto.isActive,
      };

      if (dto.isDefault) {
        await tx.companionAsset.updateMany({ data: { isDefault: false } });
      }

      const asset = await tx.companionAsset.create({ data });
      await this.ensureDefault(tx);

      return asset;
    });
  }

  async update(id: string, dto: UpdateCompanionAssetDto) {
    await this.ensureExists(id);

    return this.prisma.$transaction(async (tx) => {
      const data = {
        ...dto,
        isActive: dto.isDefault ? true : dto.isActive,
      };

      if (dto.isDefault) {
        await tx.companionAsset.updateMany({
          where: { id: { not: id } },
          data: { isDefault: false },
        });
      }

      const asset = await tx.companionAsset.update({ where: { id }, data });
      await this.ensureDefault(tx, dto.isDefault === false ? id : undefined);

      return asset;
    });
  }

  async remove(id: string) {
    await this.ensureExists(id);

    return this.prisma.$transaction(async (tx) => {
      const asset = await tx.companionAsset.delete({ where: { id } });
      await this.ensureDefault(tx);

      return asset;
    });
  }

  private async ensureExists(id: string) {
    const asset = await this.prisma.companionAsset.findUnique({
      where: { id },
      select: { id: true },
    });

    if (!asset) {
      throw AppException.notFound(
        ErrorCode.CATALOG_COMPANION_ASSET_NOT_FOUND,
        'Companion asset not found',
      );
    }
  }

  private buildWhere(query: CatalogQueryDto) {
    const where: Prisma.CompanionAssetWhereInput = {};
    const q = query.q?.trim();
    const companionType = q ? this.asCompanionType(q) : undefined;

    if (q) {
      where.OR = [
        { name: { contains: q, mode: 'insensitive' } },
        { description: { contains: q, mode: 'insensitive' } },
        { primaryColor: { contains: q, mode: 'insensitive' } },
        ...(companionType ? [{ type: companionType }] : []),
      ];
    }

    if (typeof query.isActive === 'boolean') {
      where.isActive = query.isActive;
    }

    return where;
  }

  private asCompanionType(value: string) {
    return Object.values(CompanionType).find(
      (type) => type.toLowerCase() === value.toLowerCase(),
    );
  }

  private async ensureDefault(
    tx: Prisma.TransactionClient,
    excludeId?: string,
  ) {
    const defaultAsset = await tx.companionAsset.findFirst({
      where: {
        isDefault: true,
        isActive: true,
        id: excludeId ? { not: excludeId } : undefined,
      },
      select: { id: true },
    });

    if (defaultAsset) {
      return;
    }

    const fallbackAsset = await tx.companionAsset.findFirst({
      where: {
        isActive: true,
        id: excludeId ? { not: excludeId } : undefined,
      },
      orderBy: { createdAt: 'desc' },
      select: { id: true },
    });

    if (!fallbackAsset) {
      return;
    }

    await tx.companionAsset.update({
      where: { id: fallbackAsset.id },
      data: { isDefault: true },
    });
  }
}
