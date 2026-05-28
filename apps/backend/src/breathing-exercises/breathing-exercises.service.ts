import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { CatalogQueryDto } from '../common/dto/catalog-query.dto';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { buildPage } from '../common/pagination/page';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBreathingExerciseDto } from './dto/create-breathing-exercise.dto';
import { UpdateBreathingExerciseDto } from './dto/update-breathing-exercise.dto';

@Injectable()
export class BreathingExercisesService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(query: CatalogQueryDto = {}) {
    const where = this.buildWhere(query);
    const [items, total] = await Promise.all([
      this.prisma.breathingExercise.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        skip: query.skip,
        take: query.limit,
      }),
      this.prisma.breathingExercise.count({ where }),
    ]);

    return buildPage(items, total, query);
  }

  create(dto: CreateBreathingExerciseDto) {
    return this.prisma.breathingExercise.create({ data: dto });
  }

  async update(id: string, dto: UpdateBreathingExerciseDto) {
    await this.ensureExists(id);
    return this.prisma.breathingExercise.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    await this.ensureExists(id);
    return this.prisma.breathingExercise.delete({ where: { id } });
  }

  private async ensureExists(id: string) {
    const exercise = await this.prisma.breathingExercise.findUnique({
      where: { id },
      select: { id: true },
    });

    if (!exercise) {
      throw AppException.notFound(
        ErrorCode.CATALOG_BREATHING_EXERCISE_NOT_FOUND,
        'Breathing exercise not found',
      );
    }
  }

  private buildWhere(query: CatalogQueryDto) {
    const where: Prisma.BreathingExerciseWhereInput = {};
    const q = query.q?.trim();

    if (q) {
      where.OR = [
        { title: { contains: q, mode: 'insensitive' } },
        { description: { contains: q, mode: 'insensitive' } },
      ];
    }

    if (typeof query.isActive === 'boolean') {
      where.isActive = query.isActive;
    }

    return where;
  }
}
