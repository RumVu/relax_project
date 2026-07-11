import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { CatalogQueryDto } from '../common/dto/catalog-query.dto';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { buildPage } from '../common/pagination/page';
import { PrismaService } from '../prisma/prisma.service';
import { CreateAmbientSoundDto } from './dto/create-ambient-sound.dto';
import { UpdateAmbientSoundDto } from './dto/update-ambient-sound.dto';

@Injectable()
export class AmbientSoundsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(query: CatalogQueryDto = {}) {
    const where = this.buildWhere(query);
    const [items, total] = await Promise.all([
      this.prisma.ambientSound.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: query.skip,
        take: query.limit,
      }),
      this.prisma.ambientSound.count({ where }),
    ]);

    return buildPage(items, total, query);
  }

  /**
   * Admin listing — returns all sounds including inactive ones, with
   * optional category filter.
   */
  async findAllAdmin(query: {
    category?: string;
    isActive?: boolean;
    skip?: number;
    limit?: number;
  }) {
    const where: Prisma.AmbientSoundWhereInput = {};

    if (query.category?.trim()) {
      where.category = query.category.trim().toUpperCase();
    }
    if (typeof query.isActive === 'boolean') {
      where.isActive = query.isActive;
    }

    const [items, total] = await Promise.all([
      this.prisma.ambientSound.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: query.skip ?? 0,
        take: query.limit ?? 50,
      }),
      this.prisma.ambientSound.count({ where }),
    ]);

    return buildPage(items, total, {
      skip: query.skip ?? 0,
      limit: query.limit ?? 50,
    });
  }

  findByCategory(category: string) {
    return this.prisma.ambientSound.findMany({
      where: { category, isActive: true },
      orderBy: { createdAt: 'desc' },
    });
  }

  create(dto: CreateAmbientSoundDto) {
    return this.prisma.ambientSound.create({ data: dto });
  }

  async update(id: string, dto: UpdateAmbientSoundDto) {
    await this.ensureExists(id);
    return this.prisma.ambientSound.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    await this.ensureExists(id);
    return this.prisma.ambientSound.delete({ where: { id } });
  }

  private async ensureExists(id: string) {
    const sound = await this.prisma.ambientSound.findUnique({
      where: { id },
      select: { id: true },
    });

    if (!sound) {
      throw AppException.notFound(
        ErrorCode.CATALOG_AMBIENT_SOUND_NOT_FOUND,
        'Ambient sound not found',
      );
    }
  }

  private buildWhere(query: CatalogQueryDto) {
    const where: Prisma.AmbientSoundWhereInput = {};
    const q = query.q?.trim();

    if (q) {
      where.OR = [
        { title: { contains: q, mode: 'insensitive' } },
        { description: { contains: q, mode: 'insensitive' } },
        { category: { contains: q, mode: 'insensitive' } },
      ];
    }

    where.isActive = typeof query.isActive === 'boolean' ? query.isActive : true;

    const selectedCategory = query.category?.trim().toUpperCase();
    if (query.excludeCategories?.trim()) {
      const excluded = query.excludeCategories
        .split(',')
        .map((c) => c.trim().toUpperCase())
        .filter(Boolean);
      if (excluded.length) {
        if (selectedCategory) {
          where.AND = [
            { category: selectedCategory },
            { category: { notIn: excluded } },
          ];
        } else {
          where.category = { notIn: excluded };
        }
      }
    } else if (selectedCategory) {
      where.category = selectedCategory;
    }

    return where;
  }
}
