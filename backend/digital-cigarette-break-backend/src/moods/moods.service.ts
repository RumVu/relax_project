import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateMoodDto } from './dto/create-mood.dto';
import { UpdateMoodDto } from './dto/update-mood.dto';

@Injectable()
export class MoodsService {
  constructor(private readonly prisma: PrismaService) {}

  create(userId: string, dto: CreateMoodDto) {
    return this.prisma.mood.create({
      data: {
        userId,
        type: dto.type,
        intensity: dto.intensity,
        notes: dto.notes,
        tags: dto.tags ?? [],
        activities: dto.activities ?? [],
      },
    });
  }

  findAll(userId: string) {
    return this.prisma.mood.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(userId: string, id: string) {
    const mood = await this.prisma.mood.findFirst({ where: { id, userId } });
    if (!mood) {
      throw new NotFoundException('Mood not found');
    }
    return mood;
  }

  async update(userId: string, id: string, dto: UpdateMoodDto) {
    await this.findOne(userId, id);
    return this.prisma.mood.update({
      where: { id },
      data: {
        type: dto.type,
        intensity: dto.intensity,
        notes: dto.notes,
        tags: dto.tags,
        activities: dto.activities,
      },
    });
  }

  async remove(userId: string, id: string): Promise<void> {
    await this.findOne(userId, id);
    await this.prisma.mood.delete({ where: { id } });
  }
}
