import { Injectable } from '@nestjs/common';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { CreateOnboardingSlideDto } from './dto/create-onboarding-slide.dto';
import { UpdateOnboardingSlideDto } from './dto/update-onboarding-slide.dto';

@Injectable()
export class OnboardingSlidesService {
  constructor(private readonly prisma: PrismaService) {}

  findAll() {
    return this.prisma.onboardingSlide.findMany({
      orderBy: [{ displayOrder: 'asc' }, { createdAt: 'asc' }],
    });
  }

  create(dto: CreateOnboardingSlideDto) {
    return this.prisma.onboardingSlide.create({ data: dto });
  }

  async update(id: string, dto: UpdateOnboardingSlideDto) {
    await this.ensureExists(id);
    return this.prisma.onboardingSlide.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    await this.ensureExists(id);
    return this.prisma.onboardingSlide.delete({ where: { id } });
  }

  private async ensureExists(id: string) {
    const slide = await this.prisma.onboardingSlide.findUnique({
      where: { id },
      select: { id: true },
    });

    if (!slide) {
      throw AppException.notFound(
        ErrorCode.CATALOG_ONBOARDING_SLIDE_NOT_FOUND,
        'Onboarding slide not found',
      );
    }
  }
}
