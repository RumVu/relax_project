import { Injectable } from '@nestjs/common';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { UpsertUserPreferenceDto } from './dto/upsert-user-preference.dto';

@Injectable()
export class UserPreferencesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
  ) {}

  async findByUserId(userId: string) {
    await this.usersService.findOne(userId);
    const preferences = await this.prisma.userPreference.findUnique({
      where: { userId },
      include: { theme: true },
    });

    if (!preferences) {
      throw AppException.notFound(
        ErrorCode.USER_PREFERENCE_NOT_FOUND,
        'User preferences not found',
      );
    }

    return preferences;
  }

  async upsert(userId: string, dto: UpsertUserPreferenceDto) {
    await this.usersService.findOne(userId);

    return this.prisma.userPreference.upsert({
      where: { userId },
      create: { userId, ...dto },
      update: dto,
      include: { theme: true },
    });
  }
}
