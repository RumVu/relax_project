import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { CatalogQueryDto } from '../common/dto/catalog-query.dto';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBreathingExerciseDto } from './dto/create-breathing-exercise.dto';
import { UpdateBreathingExerciseDto } from './dto/update-breathing-exercise.dto';

@Injectable()
export class BreathingExercisesService {
  constructor(private readonly prisma: PrismaService) {}

  findAll(query: CatalogQueryDto = {}) {
    return this.prisma.breathingExercise.findMany({
      where: this.buildWhere(query),
      orderBy: { createdAt: 'desc' },
      skip: query.skip,
      take: query.limit,
    });
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
