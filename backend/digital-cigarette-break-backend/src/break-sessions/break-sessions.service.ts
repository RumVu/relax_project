import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateBreakSessionDto } from './dto/create-break-session.dto';
import { UpdateBreakSessionDto } from './dto/update-break-session.dto';

function toDate(value?: string): Date | undefined {
  return value ? new Date(value) : undefined;
}

@Injectable()
export class BreakSessionsService {
  constructor(private readonly prisma: PrismaService) {}

  create(userId: string, dto: CreateBreakSessionDto) {
    return this.prisma.breakSession.create({
      data: {
        userId,
        mode: dto.mode,
        duration: dto.duration,
        plannedDuration: dto.plannedDuration,
        status: dto.status,
        startedAt: new Date(dto.startedAt),
        endedAt: toDate(dto.endedAt),
        completedAt: toDate(dto.completedAt),
        notes: dto.notes,
        activities: dto.activities ?? [],
      },
    });
  }

  findAll(userId: string) {
    return this.prisma.breakSession.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(userId: string, id: string) {
    const session = await this.prisma.breakSession.findFirst({
      where: { id, userId },
    });
    if (!session) {
      throw new NotFoundException('Break session not found');
    }
    return session;
  }

  async update(userId: string, id: string, dto: UpdateBreakSessionDto) {
    await this.findOne(userId, id);
    return this.prisma.breakSession.update({
      where: { id },
      data: {
        mode: dto.mode,
        duration: dto.duration,
        plannedDuration: dto.plannedDuration,
        status: dto.status,
        startedAt: toDate(dto.startedAt),
        endedAt: toDate(dto.endedAt),
        completedAt: toDate(dto.completedAt),
        notes: dto.notes,
        activities: dto.activities,
      },
    });
  }

  async remove(userId: string, id: string): Promise<void> {
    await this.findOne(userId, id);
    await this.prisma.breakSession.delete({ where: { id } });
  }
}
