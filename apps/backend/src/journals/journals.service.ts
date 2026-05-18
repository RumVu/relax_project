import { ForbiddenException, Injectable } from '@nestjs/common';
import { Journal, Prisma, UserRole } from '@prisma/client';
import type { AuthUser } from '../auth/auth.types';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { CreateJournalDto } from './dto/create-journal.dto';
import { JournalQueryDto } from './dto/journal-query.dto';
import { UpdateJournalDto } from './dto/update-journal.dto';

@Injectable()
export class JournalsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
  ) {}

  async findMine(userId: string, query: JournalQueryDto) {
    await this.usersService.findOne(userId);
    return this.prisma.journal.findMany({
      where: this.buildWhere(userId, query),
      orderBy: { createdAt: 'desc' },
      skip: query.skip,
      take: query.limit ?? 50,
    });
  }

  async findByUserId(userId: string, query: JournalQueryDto) {
    await this.usersService.findOne(userId);
    return this.prisma.journal.findMany({
      where: this.buildWhere(userId, query),
      orderBy: { createdAt: 'desc' },
      skip: query.skip,
      take: query.limit ?? 50,
    });
  }

  async findOne(id: string, user: AuthUser) {
    const journal = await this.findExisting(id);
    this.assertOwnerOrAdmin(journal, user);
    return journal;
  }

  async create(userId: string, dto: CreateJournalDto) {
    await this.usersService.findOne(userId);
    const journal = await this.prisma.journal.create({
      data: {
        userId,
        title: dto.title,
        content: dto.content,
        mood: dto.mood,
        tags: dto.tags ?? [],
        isPrivate: dto.isPrivate ?? true,
        isFavorite: dto.isFavorite ?? false,
      },
    });
    await this.syncProfileJournalCount(userId);
    return journal;
  }

  async update(id: string, dto: UpdateJournalDto, user: AuthUser) {
    const journal = await this.findExisting(id);
    this.assertOwnerOrAdmin(journal, user);
    return this.prisma.journal.update({ where: { id }, data: dto });
  }

  async remove(id: string, user: AuthUser) {
    const journal = await this.findExisting(id);
    this.assertOwnerOrAdmin(journal, user);
    const removed = await this.prisma.journal.delete({ where: { id } });
    await this.syncProfileJournalCount(removed.userId);
    return removed;
  }

  async getStats(userId: string, query: JournalQueryDto) {
    await this.usersService.findOne(userId);
    const where = this.buildWhere(userId, query);
    const [total, favorites, byMood, recent] = await Promise.all([
      this.prisma.journal.count({ where }),
      this.prisma.journal.count({ where: { ...where, isFavorite: true } }),
      this.prisma.journal.groupBy({
        by: ['mood'],
        where,
        _count: { mood: true },
      }),
      this.prisma.journal.findMany({
        where,
        orderBy: { createdAt: 'desc' },
        take: 5,
      }),
    ]);

    return {
      total,
      favorites,
      byMood: byMood.map((entry) => ({
        mood: entry.mood,
        count: entry._count.mood,
      })),
      recent,
    };
  }

  private async findExisting(id: string) {
    const journal = await this.prisma.journal.findUnique({ where: { id } });
    if (!journal) {
      throw AppException.notFound(
        ErrorCode.JOURNAL_NOT_FOUND,
        'Journal not found',
      );
    }
    return journal;
  }

  private assertOwnerOrAdmin(journal: Journal, user: AuthUser) {
    if (user.role === UserRole.ADMIN || journal.userId === user.id) {
      return;
    }
    throw new ForbiddenException({
      code: ErrorCode.AUTH_FORBIDDEN,
      message: 'You do not have permission to access this journal',
    });
  }

  private buildWhere(userId: string, query: JournalQueryDto) {
    const where: Prisma.JournalWhereInput = { userId };
    if (query.mood) where.mood = query.mood;
    if (query.tag) where.tags = { has: query.tag };
    if (typeof query.isFavorite === 'boolean') {
      where.isFavorite = query.isFavorite;
    }
    if (query.from || query.to) {
      where.createdAt = { gte: query.from, lte: query.to };
    }
    return where;
  }

  private async syncProfileJournalCount(userId: string) {
    const count = await this.prisma.journal.count({ where: { userId } });
    await this.prisma.userProfile.updateMany({
      where: { userId },
      data: { totalJournalPosts: count },
    });
  }
}
