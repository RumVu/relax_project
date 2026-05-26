import { Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import { buildPage } from '../common/pagination/page';
import { PrismaService } from '../prisma/prisma.service';
import { AdminLogQueryDto } from './dto/admin-log-query.dto';

@Injectable()
export class AdminLogsService {
  constructor(private readonly prisma: PrismaService) {}

  async findAll(query: AdminLogQueryDto = {}) {
    const where: Prisma.AdminLogWhereInput = {
      adminId: query.adminId,
      action: query.action
        ? { contains: query.action, mode: 'insensitive' }
        : undefined,
      targetType: query.targetType,
      targetId: query.targetId,
      createdAt:
        query.from || query.to
          ? {
              gte: query.from,
              lte: query.to,
            }
          : undefined,
    };

    const [items, total] = await Promise.all([
      this.prisma.adminLog.findMany({
        where,
        include: {
          admin: {
            select: {
              id: true,
              email: true,
              name: true,
              role: true,
            },
          },
        },
        orderBy: { createdAt: 'desc' },
        skip: query.skip,
        take: query.limit ?? 50,
      }),
      this.prisma.adminLog.count({ where }),
    ]);

    return buildPage(items, total, query);
  }
}
