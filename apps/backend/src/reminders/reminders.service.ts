import { ForbiddenException, Injectable } from '@nestjs/common';
import { Prisma, Reminder, UserRole } from '@prisma/client';
import type { AuthUser } from '../auth/auth.types';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { buildPage } from '../common/pagination/page';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { CreateReminderDto } from './dto/create-reminder.dto';
import { ReminderQueryDto } from './dto/reminder-query.dto';
import { UpdateReminderDto } from './dto/update-reminder.dto';

@Injectable()
export class RemindersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
  ) {}

  async listMine(userId: string, query: ReminderQueryDto) {
    await this.usersService.findOne(userId);
    return this.listByWhere(this.buildWhere(userId, query), query);
  }

  async listAll(query: ReminderQueryDto) {
    return this.listByWhere(this.buildWhere(undefined, query), query);
  }

  async listByUserId(userId: string, query: ReminderQueryDto) {
    await this.usersService.findOne(userId);
    return this.listByWhere(this.buildWhere(userId, query), query);
  }

  async getStats(userId: string) {
    await this.usersService.findOne(userId);
    const [total, active, upcoming, byType] = await Promise.all([
      this.prisma.reminder.count({ where: { userId } }),
      this.prisma.reminder.count({ where: { userId, isActive: true } }),
      this.prisma.reminder.count({
        where: {
          userId,
          isActive: true,
          scheduledAt: { gte: new Date() },
        },
      }),
      this.prisma.reminder.groupBy({
        by: ['type'],
        where: { userId },
        _count: { type: true },
      }),
    ]);

    return {
      total,
      active,
      upcoming,
      byType: byType.map((entry) => ({
        type: entry.type,
        count: entry._count.type,
      })),
    };
  }

  async create(userId: string, dto: CreateReminderDto) {
    await this.usersService.findOne(userId);

    return this.prisma.reminder.create({
      data: {
        userId,
        title: dto.title,
        message: dto.message,
        type: dto.type,
        scheduledAt: dto.scheduledAt,
        repeatRule: dto.repeatRule,
        isActive: dto.isActive ?? true,
      },
    });
  }

  async findOne(id: string, user: AuthUser) {
    const reminder = await this.findExisting(id);
    this.assertOwnerOrAdmin(reminder, user);
    return reminder;
  }

  async update(id: string, dto: UpdateReminderDto, user: AuthUser) {
    const reminder = await this.findExisting(id);
    this.assertOwnerOrAdmin(reminder, user);

    return this.prisma.reminder.update({
      where: { id },
      data: dto,
    });
  }

  async remove(id: string, user: AuthUser) {
    const reminder = await this.findExisting(id);
    this.assertOwnerOrAdmin(reminder, user);

    const removed = await this.prisma.reminder.delete({
      where: { id },
    });

    return { success: true, id: removed.id };
  }

  private async listByWhere(
    where: Prisma.ReminderWhereInput,
    query: ReminderQueryDto,
  ) {
    const [items, total] = await Promise.all([
      this.prisma.reminder.findMany({
        where,
        orderBy: { scheduledAt: 'asc' },
        skip: query.skip,
        take: query.limit ?? 50,
      }),
      this.prisma.reminder.count({ where }),
    ]);

    return buildPage(items, total, query);
  }

  private async findExisting(id: string) {
    const reminder = await this.prisma.reminder.findUnique({ where: { id } });
    if (!reminder) {
      throw AppException.notFound(
        ErrorCode.REMINDER_NOT_FOUND,
        'Reminder not found',
      );
    }
    return reminder;
  }

  private buildWhere(userId: string | undefined, query: ReminderQueryDto) {
    const where: Prisma.ReminderWhereInput = {
      userId,
      type: query.type,
      isActive: query.isActive,
    };

    if (query.from || query.to) {
      where.scheduledAt = { gte: query.from, lte: query.to };
    }

    return where;
  }

  private assertOwnerOrAdmin(reminder: Reminder, user: AuthUser) {
    if (user.role === UserRole.ADMIN || reminder.userId === user.id) {
      return;
    }

    throw new ForbiddenException({
      code: ErrorCode.AUTH_FORBIDDEN,
      message: 'You do not have permission to access this reminder',
    });
  }
}
