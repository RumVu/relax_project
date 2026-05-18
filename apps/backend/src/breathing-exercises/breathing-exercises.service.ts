import { Injectable } from '@nestjs/common';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBreathingExerciseDto } from './dto/create-breathing-exercise.dto';
import { UpdateBreathingExerciseDto } from './dto/update-breathing-exercise.dto';

@Injectable()
export class BreathingExercisesService {
  constructor(private readonly prisma: PrismaService) {}

  findAll() {
    return this.prisma.breathingExercise.findMany({
      orderBy: { createdAt: 'desc' },
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
}
