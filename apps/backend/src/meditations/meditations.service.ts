import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { CreateMeditationSessionDto } from './dto/create-meditation-session.dto';
import { CreateMeditationGuideDto } from './dto/create-meditation-guide.dto';
import { UpdateMeditationGuideDto } from './dto/update-meditation-guide.dto';

@Injectable()
export class MeditationsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
  ) {}

  async findGuides(difficulty?: string, focusArea?: string, isAdmin = false) {
    const guides = await this.prisma.meditationGuide.findMany({
      where: {
        ...(!isAdmin && { isActive: true }),
        difficulty: difficulty ? difficulty.toUpperCase() : undefined,
        focusArea: focusArea || undefined,
      },
      orderBy: { createdAt: 'desc' },
    });

    return guides.map((g) => ({
      ...g,
      type: g.focusArea,
      durationMinutes: g.duration,
    }));
  }

  async createGuide(dto: CreateMeditationGuideDto) {
    const focusArea = dto.type || dto.focusArea || 'GUIDED';
    const duration =
      dto.durationMinutes !== undefined
        ? dto.durationMinutes
        : dto.duration !== undefined
          ? dto.duration
          : 5;

    const guide = await this.prisma.meditationGuide.create({
      data: {
        title: dto.title,
        description: dto.description || null,
        focusArea,
        duration:
          typeof duration === 'string' ? parseInt(duration, 10) : duration,
        audioUrl: dto.audioUrl || null,
        imageUrl: dto.imageUrl || null,
        difficulty: dto.difficulty || 'BEGINNER',
        instructor: dto.instructor || 'Admin',
        isActive: dto.isActive !== undefined ? dto.isActive : true,
      },
    });

    return {
      ...guide,
      type: guide.focusArea,
      durationMinutes: guide.duration,
    };
  }

  async updateGuide(id: string, dto: UpdateMeditationGuideDto) {
    const data: {
      title?: string;
      description?: string | null;
      focusArea?: string;
      duration?: number;
      audioUrl?: string | null;
      imageUrl?: string | null;
      difficulty?: string;
      instructor?: string;
      isActive?: boolean;
    } = {};
    if (dto.title !== undefined) data.title = dto.title;
    if (dto.description !== undefined)
      data.description = dto.description || null;
    if (dto.type !== undefined || dto.focusArea !== undefined) {
      data.focusArea = dto.type || dto.focusArea;
    }
    if (dto.durationMinutes !== undefined || dto.duration !== undefined) {
      const dur =
        dto.durationMinutes !== undefined ? dto.durationMinutes : dto.duration;
      data.duration = typeof dur === 'string' ? parseInt(dur, 10) : (dur ?? 5);
    }
    if (dto.audioUrl !== undefined) data.audioUrl = dto.audioUrl || null;
    if (dto.imageUrl !== undefined) data.imageUrl = dto.imageUrl || null;
    if (dto.difficulty !== undefined) data.difficulty = dto.difficulty;
    if (dto.instructor !== undefined) data.instructor = dto.instructor;
    if (dto.isActive !== undefined) data.isActive = dto.isActive;

    const guide = await this.prisma.meditationGuide.update({
      where: { id },
      data,
    });

    return {
      ...guide,
      type: guide.focusArea,
      durationMinutes: guide.duration,
    };
  }

  async deleteGuide(id: string) {
    const guide = await this.prisma.meditationGuide.delete({
      where: { id },
    });
    return {
      ...guide,
      type: guide.focusArea,
      durationMinutes: guide.duration,
    };
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
