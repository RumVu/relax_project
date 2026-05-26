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

  async create(dto: CreateOnboardingSlideDto) {
    const slide = await this.prisma.onboardingSlide.create({ data: dto });
    await this.upsertSearchIndex(slide);

    return slide;
  }

  async update(id: string, dto: UpdateOnboardingSlideDto) {
    await this.ensureExists(id);
    const slide = await this.prisma.onboardingSlide.update({
      where: { id },
      data: dto,
    });
    await this.upsertSearchIndex(slide);

    return slide;
  }

  async remove(id: string) {
    await this.ensureExists(id);
    const slide = await this.prisma.onboardingSlide.delete({ where: { id } });
    await this.prisma.searchIndex.deleteMany({
      where: { entityType: 'ONBOARDING_SLIDE', entityId: id },
    });

    return slide;
  }

  private upsertSearchIndex(slide: {
    id: string;
    title: string;
    subtitle: string | null;
    description: string | null;
    displayOrder: number;
    isActive: boolean;
  }) {
    return this.prisma.searchIndex.upsert({
      where: {
        entityType_entityId: {
          entityType: 'ONBOARDING_SLIDE',
          entityId: slide.id,
        },
      },
      update: this.searchIndexPayload(slide),
      create: {
        entityType: 'ONBOARDING_SLIDE',
        entityId: slide.id,
        ...this.searchIndexPayload(slide),
      },
    });
  }

  private searchIndexPayload(slide: {
    title: string;
    subtitle: string | null;
    description: string | null;
    displayOrder: number;
    isActive: boolean;
  }) {
    return {
      title: slide.title,
      content: [
        slide.title,
        slide.subtitle,
        slide.description,
        `order ${slide.displayOrder}`,
        slide.isActive ? 'active' : 'draft',
      ]
        .filter(Boolean)
        .join(' '),
      tags: [
        'onboarding',
        'slide',
        `order-${slide.displayOrder}`,
        slide.isActive ? 'active' : 'draft',
      ],
    };
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
