import { Injectable, NotFoundException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateJournalDto } from './dto/create-journal.dto';
import { UpdateJournalDto } from './dto/update-journal.dto';

@Injectable()
export class JournalsService {
  constructor(private readonly prisma: PrismaService) {}

  create(userId: string, dto: CreateJournalDto) {
    return this.prisma.journal.create({
      data: {
        userId,
        title: dto.title,
        content: dto.content,
        mood: dto.mood,
        tags: dto.tags ?? [],
        isPrivate: dto.isPrivate,
        isFavorite: dto.isFavorite,
      },
    });
  }

  findAll(userId: string) {
    return this.prisma.journal.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(userId: string, id: string) {
    const journal = await this.prisma.journal.findFirst({
      where: { id, userId },
    });
    if (!journal) {
      throw new NotFoundException('Journal not found');
    }
    return journal;
  }

  async update(userId: string, id: string, dto: UpdateJournalDto) {
    await this.findOne(userId, id);
    return this.prisma.journal.update({
      where: { id },
      data: {
        title: dto.title,
        content: dto.content,
        mood: dto.mood,
        tags: dto.tags,
        isPrivate: dto.isPrivate,
        isFavorite: dto.isFavorite,
      },
    });
  }

  async remove(userId: string, id: string): Promise<void> {
    await this.findOne(userId, id);
    await this.prisma.journal.delete({ where: { id } });
  }
}
