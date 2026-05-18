import { ConflictException, Injectable } from '@nestjs/common';
import { Prisma } from '@prisma/client';
import * as bcrypt from 'bcrypt';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { userSelect } from './user.select';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  findAll() {
    return this.prisma.user.findMany({
      select: userSelect,
      orderBy: { createdAt: 'desc' },
    });
  }

  async findOne(id: string) {
    const user = await this.prisma.user.findUnique({
      where: { id },
      select: userSelect,
    });

    if (!user) {
      throw AppException.notFound(ErrorCode.USER_NOT_FOUND, 'User not found');
    }

    return user;
  }

  findByEmailWithPassword(email: string) {
    return this.prisma.user.findUnique({
      where: { email },
      include: { profile: true, preferences: true },
    });
  }

  async create(dto: CreateUserDto) {
    const password = dto.password
      ? await bcrypt.hash(dto.password, 12)
      : undefined;

    try {
      return await this.prisma.user.create({
        data: {
          email: dto.email,
          name: dto.name,
          avatar: dto.avatar,
          password,
          role: dto.role,
          authProvider: dto.authProvider,
          emailVerified: dto.emailVerified,
          isActive: dto.isActive,
          profile: { create: { displayName: dto.name } },
          preferences: { create: {} },
        },
        select: userSelect,
      });
    } catch (error) {
      this.handleKnownUserError(error);
    }
  }

  async update(id: string, dto: UpdateUserDto) {
    await this.findOne(id);
    const password = dto.password
      ? await bcrypt.hash(dto.password, 12)
      : undefined;

    try {
      return await this.prisma.user.update({
        where: { id },
        data: {
          email: dto.email,
          name: dto.name,
          avatar: dto.avatar,
          password,
          role: dto.role,
          authProvider: dto.authProvider,
          emailVerified: dto.emailVerified,
          isActive: dto.isActive,
        },
        select: userSelect,
      });
    } catch (error) {
      this.handleKnownUserError(error);
    }
  }

  async remove(id: string) {
    await this.findOne(id);

    return this.prisma.user.delete({
      where: { id },
      select: userSelect,
    });
  }

  private handleKnownUserError(error: unknown): never {
    if (
      error instanceof Prisma.PrismaClientKnownRequestError &&
      error.code === 'P2002'
    ) {
      throw new ConflictException({
        code: ErrorCode.USER_EMAIL_ALREADY_EXISTS,
        message: 'User email already exists',
        details: error.meta,
      });
    }

    throw error;
  }
}
