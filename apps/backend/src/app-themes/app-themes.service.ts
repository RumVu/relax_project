import { Injectable } from '@nestjs/common';
import { Prisma, ThemeMode } from '@prisma/client';
import { CatalogQueryDto } from '../common/dto/catalog-query.dto';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { CreateAppThemeDto } from './dto/create-app-theme.dto';
import { UpdateAppThemeDto } from './dto/update-app-theme.dto';

@Injectable()
export class AppThemesService {
  constructor(private readonly prisma: PrismaService) {}

  findAll(query: CatalogQueryDto = {}) {
    return this.prisma.appTheme.findMany({
      where: this.buildWhere(query),
      orderBy: [{ isDefault: 'desc' }, { createdAt: 'desc' }],
      skip: query.skip,
      take: query.limit,
    });
  }

  async findDefault() {
    const theme = await this.prisma.appTheme.findFirst({
      where: { isDefault: true, isActive: true },
      orderBy: { createdAt: 'desc' },
    });

    if (!theme) {
      throw AppException.notFound(
        ErrorCode.CATALOG_DEFAULT_APP_THEME_NOT_FOUND,
        'Default app theme not found',
      );
    }

    return theme;
  }

  async create(dto: CreateAppThemeDto) {
    return this.prisma.$transaction(async (tx) => {
      const data = {
        ...dto,
        isActive: dto.isDefault ? true : dto.isActive,
      };

      if (dto.isDefault) {
        await tx.appTheme.updateMany({ data: { isDefault: false } });
      }

      const theme = await tx.appTheme.create({ data });
      await this.ensureDefault(tx);

      return theme;
    });
  }

  async update(id: string, dto: UpdateAppThemeDto) {
    await this.ensureExists(id);

    return this.prisma.$transaction(async (tx) => {
      const data = {
        ...dto,
        isActive: dto.isDefault ? true : dto.isActive,
      };

      if (dto.isDefault) {
        await tx.appTheme.updateMany({
          where: { id: { not: id } },
          data: { isDefault: false },
        });
      }

      const theme = await tx.appTheme.update({ where: { id }, data });
      await this.ensureDefault(tx, dto.isDefault === false ? id : undefined);

      return theme;
    });
  }

  async remove(id: string) {
    await this.ensureExists(id);

    return this.prisma.$transaction(async (tx) => {
      const theme = await tx.appTheme.delete({ where: { id } });
      await this.ensureDefault(tx);

      return theme;
    });
  }

  private async ensureExists(id: string) {
    const theme = await this.prisma.appTheme.findUnique({
      where: { id },
      select: { id: true },
    });

    if (!theme) {
      throw AppException.notFound(
        ErrorCode.CATALOG_APP_THEME_NOT_FOUND,
        'App theme not found',
      );
    }
  }

  private buildWhere(query: CatalogQueryDto) {
    const where: Prisma.AppThemeWhereInput = {};
    const q = query.q?.trim();
    const themeMode = q ? this.asThemeMode(q) : undefined;

    if (q) {
      where.OR = [
        { name: { contains: q, mode: 'insensitive' } },
        { primaryColor: { contains: q, mode: 'insensitive' } },
        { backgroundColor: { contains: q, mode: 'insensitive' } },
        ...(themeMode ? [{ mode: themeMode }] : []),
      ];
    }

    if (typeof query.isActive === 'boolean') {
      where.isActive = query.isActive;
    }

    return where;
  }

  private asThemeMode(value: string) {
    return Object.values(ThemeMode).find(
      (mode) => mode.toLowerCase() === value.toLowerCase(),
    );
  }

  private async ensureDefault(
    tx: Prisma.TransactionClient,
    excludeId?: string,
  ) {
    const defaultTheme = await tx.appTheme.findFirst({
      where: {
        isDefault: true,
        isActive: true,
        id: excludeId ? { not: excludeId } : undefined,
      },
      select: { id: true },
    });

    if (defaultTheme) {
      return;
    }

    const fallbackTheme = await tx.appTheme.findFirst({
      where: {
        isActive: true,
        id: excludeId ? { not: excludeId } : undefined,
      },
      orderBy: { createdAt: 'desc' },
      select: { id: true },
    });

    if (!fallbackTheme) {
      return;
    }

    await tx.appTheme.update({
      where: { id: fallbackTheme.id },
      data: { isDefault: true },
    });
  }
}
