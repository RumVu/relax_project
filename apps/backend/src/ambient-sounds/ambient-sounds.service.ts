import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { CatalogQueryDto } from '../common/dto/catalog-query.dto';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { CreateAmbientSoundDto } from './dto/create-ambient-sound.dto';
import { UpdateAmbientSoundDto } from './dto/update-ambient-sound.dto';

@Injectable()
export class AmbientSoundsService {
  constructor(private readonly prisma: PrismaService) {}

  findAll(query: CatalogQueryDto = {}) {
    return this.prisma.ambientSound.findMany({
      where: this.buildWhere(query),
      orderBy: { createdAt: 'desc' },
      skip: query.skip,
      take: query.limit,
    });
  }

  findByCategory(category: string) {
    return this.prisma.ambientSound.findMany({
      where: { category },
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

    if (typeof query.isActive === 'boolean') {
      where.isActive = query.isActive;
    }

    return where;
  }
}
