import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { CreateMeditationSessionDto } from './dto/create-meditation-session.dto';

@Injectable()
export class MeditationsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
  ) {}

  async findGuides(difficulty?: string, focusArea?: string) {
    return this.prisma.meditationGuide.findMany({
      where: {
        isActive: true,
        difficulty: difficulty ? difficulty.toUpperCase() : undefined,
        focusArea: focusArea || undefined,
      },
      orderBy: { createdAt: 'desc' },
    });
  }

  async createSession(userId: string, dto: CreateMeditationSessionDto) {
    await this.usersService.findOne(userId);
    return this.prisma.meditationSession.create({
      data: {
        userId,
        guideId: dto.guideId || null,
        duration: dto.duration,
        startedAt: new Date(dto.startedAt),
        endedAt: dto.endedAt ? new Date(dto.endedAt) : null,
        focusArea: dto.focusArea || null,
        mood: dto.mood || null,
        quality: dto.quality || null,
        notes: dto.notes || null,
      },
      include: { guide: true },
    });
  }

  async findSessions(userId: string) {
    await this.usersService.findOne(userId);
    return this.prisma.meditationSession.findMany({
      where: { userId },
      orderBy: { startedAt: 'desc' },
      include: { guide: true },
    });
  }
}
