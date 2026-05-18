import { Injectable } from '@nestjs/common';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';

const sessionSelect = {
  id: true,
  userId: true,
  userAgent: true,
  ipAddress: true,
  expiresAt: true,
  createdAt: true,
} as const;

@Injectable()
export class SessionsService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
  ) {}

  async findAll() {
    return this.prisma.session.findMany({
      orderBy: { createdAt: 'desc' },
      select: {
        ...sessionSelect,
        user: {
          select: {
            id: true,
            email: true,
            name: true,
            role: true,
            isActive: true,
          },
        },
      },
    });
  }

  async findByUserId(userId: string) {
    await this.usersService.findOne(userId);

    return this.prisma.session.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
      select: sessionSelect,
    });
  }

  async revoke(id: string) {
    const session = await this.prisma.session.findUnique({
      where: { id },
    });

    if (!session) {
      throw AppException.notFound(
        ErrorCode.SESSION_NOT_FOUND,
        'Session not found',
      );
    }

    return this.prisma.session.delete({
      where: { id },
      select: sessionSelect,
    });
  }

  async revokeUserSessions(userId: string) {
    await this.usersService.findOne(userId);
    const result = await this.prisma.session.deleteMany({ where: { userId } });

    return {
      revoked: result.count,
    };
  }
}
