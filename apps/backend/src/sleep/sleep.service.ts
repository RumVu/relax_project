import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { CreateSleepSessionDto } from './dto/create-sleep-session.dto';

@Injectable()
export class SleepService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
  ) {}

  async createSession(userId: string, dto: CreateSleepSessionDto) {
    await this.usersService.findOne(userId);
    return this.prisma.sleepSession.create({
      data: {
        userId,
        startedAt: new Date(dto.startedAt),
        endedAt: dto.endedAt ? new Date(dto.endedAt) : null,
        quality: dto.quality || null,
        note: dto.note || null,
      },
    });
  }

  async findSessions(userId: string) {
    await this.usersService.findOne(userId);
    return this.prisma.sleepSession.findMany({
      where: { userId },
      orderBy: { startedAt: 'desc' },
    });
  }
}
