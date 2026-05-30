import { Injectable } from '@nestjs/common';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { UpsertUserProfileDto } from './dto/upsert-user-profile.dto';
import { getZodiacPersonalization } from './zodiac';

@Injectable()
export class UserProfilesService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
  ) {}

  async findByUserId(userId: string) {
    await this.usersService.findOne(userId);
    const profile = await this.prisma.userProfile.findUnique({
      where: { userId },
    });

    if (!profile) {
      throw AppException.notFound(
        ErrorCode.USER_PROFILE_NOT_FOUND,
        'User profile not found',
      );
    }

    return profile;
  }

  async upsert(userId: string, dto: UpsertUserProfileDto) {
    await this.usersService.findOne(userId);

    // Avatar lives on the User table, not UserProfile. Pull it out so it
    // doesn't end up in the profile upsert (Prisma would reject the
    // unknown field) and apply it as a separate User update.
    const { avatar, ...profileDto } = dto;

    if (avatar !== undefined) {
      await this.prisma.user.update({
        where: { id: userId },
        data: { avatar },
      });
    }

    const zodiac = getZodiacPersonalization(profileDto.birthday);
    const payload = {
      ...profileDto,
      ...(profileDto.birthday
        ? zodiac
        : {
            zodiacSign: undefined,
            chineseZodiac: undefined,
          }),
    };

    return this.prisma.userProfile.upsert({
      where: { userId },
      create: { userId, ...payload },
      update: payload,
    });
  }
}
