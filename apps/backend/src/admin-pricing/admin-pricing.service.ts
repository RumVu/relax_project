import {
  ConflictException,
  HttpStatus,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { Prisma, SubscriptionTier } from '@prisma/client';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { CreateTierDto, UpdateTierDto } from './dto/upsert-tier.dto';

/**
 * Admin-side CRUD for SubscriptionTier rows. Public billing service still
 * reads the same table; this layer just lets admin edit price / sale /
 * activation without touching code.
 */
@Injectable()
export class AdminPricingService {
  private readonly logger = new Logger(AdminPricingService.name);
  constructor(private readonly prisma: PrismaService) {}

  /** Read everything for the admin table (active + inactive). */
  list() {
    return this.prisma.subscriptionTier.findMany({
      orderBy: [{ displayOrder: 'asc' }, { price: 'asc' }],
    });
  }

  findOne(id: string) {
    return this.requireTier(id);
  }

  async create(dto: CreateTierDto) {
    this.validateSaleWindow(dto);
    try {
      const tier = await this.prisma.subscriptionTier.create({
        data: {
          name: dto.name,
          title: dto.title ?? null,
          description: dto.description ?? null,
          price: dto.price,
          salePrice: dto.salePrice ?? null,
          saleLabel: dto.saleLabel ?? null,
          saleStartsAt: dto.saleStartsAt ? new Date(dto.saleStartsAt) : null,
          saleEndsAt: dto.saleEndsAt ? new Date(dto.saleEndsAt) : null,
          currency: dto.currency ?? 'VND',
          billingCycle: dto.billingCycle,
          displayOrder: dto.displayOrder ?? 0,
          isActive: dto.isActive ?? true,
        },
      });
      this.logger.log(
        `Tier created: ${tier.name} @ ${tier.price} ${tier.currency}`,
      );
      return tier;
    } catch (err) {
      if (
        err instanceof Prisma.PrismaClientKnownRequestError &&
        err.code === 'P2002'
      ) {
        throw new ConflictException({
          code: ErrorCode.VALIDATION_FAILED,
          message: `Tier name "${dto.name}" already exists.`,
        });
      }
      throw err;
    }
  }

  async update(id: string, dto: UpdateTierDto) {
    const existing = await this.requireTier(id);
    const merged = { ...existing, ...dto } as Partial<SubscriptionTier> &
      UpdateTierDto;
    this.validateSaleWindow(merged);

    const data: Prisma.SubscriptionTierUpdateInput = {};
    if (dto.name !== undefined) data.name = dto.name;
    if (dto.title !== undefined) data.title = dto.title || null;
    if (dto.description !== undefined)
      data.description = dto.description || null;
    if (dto.price !== undefined) data.price = dto.price;
    if (dto.salePrice !== undefined) data.salePrice = dto.salePrice;
    if (dto.saleLabel !== undefined) data.saleLabel = dto.saleLabel || null;
    if (dto.saleStartsAt !== undefined)
      data.saleStartsAt = dto.saleStartsAt ? new Date(dto.saleStartsAt) : null;
    if (dto.saleEndsAt !== undefined)
      data.saleEndsAt = dto.saleEndsAt ? new Date(dto.saleEndsAt) : null;
    if (dto.currency !== undefined) data.currency = dto.currency;
    if (dto.billingCycle !== undefined) data.billingCycle = dto.billingCycle;
    if (dto.displayOrder !== undefined) data.displayOrder = dto.displayOrder;
    if (dto.isActive !== undefined) data.isActive = dto.isActive;

    try {
      return await this.prisma.subscriptionTier.update({ where: { id }, data });
    } catch (err) {
      if (
        err instanceof Prisma.PrismaClientKnownRequestError &&
        err.code === 'P2002'
      ) {
        throw new ConflictException({
          code: ErrorCode.VALIDATION_FAILED,
          message: `Tier name "${dto.name}" already exists.`,
        });
      }
      throw err;
    }
  }

  /** Soft-disable instead of hard delete — payments may reference the row. */
  async deactivate(id: string) {
    await this.requireTier(id);
    return this.prisma.subscriptionTier.update({
      where: { id },
      data: { isActive: false },
    });
  }

  async clearSale(id: string) {
    await this.requireTier(id);
    return this.prisma.subscriptionTier.update({
      where: { id },
      data: {
        salePrice: null,
        saleLabel: null,
        saleStartsAt: null,
        saleEndsAt: null,
      },
    });
  }

  private async requireTier(id: string) {
    const tier = await this.prisma.subscriptionTier.findUnique({
      where: { id },
    });
    if (!tier) {
      throw new NotFoundException({
        code: ErrorCode.DATABASE_RECORD_NOT_FOUND,
        message: `Tier ${id} not found`,
      });
    }
    return tier;
  }

  private validateSaleWindow(
    dto: Partial<{
      salePrice: number | null;
      saleStartsAt: string | Date | null;
      saleEndsAt: string | Date | null;
      price: number;
    }>,
  ) {
    const hasSalePrice = dto.salePrice !== null && dto.salePrice !== undefined;
    const hasStart = Boolean(dto.saleStartsAt);
    const hasEnd = Boolean(dto.saleEndsAt);

    if (hasSalePrice && (!hasStart || !hasEnd)) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        'salePrice requires both saleStartsAt and saleEndsAt.',
        HttpStatus.BAD_REQUEST,
      );
    }
    if (hasStart && hasEnd) {
      const start = new Date(dto.saleStartsAt as any).getTime();
      const end = new Date(dto.saleEndsAt as any).getTime();
      if (Number.isFinite(start) && Number.isFinite(end) && end <= start) {
        throw new AppException(
          ErrorCode.VALIDATION_FAILED,
          'saleEndsAt must be after saleStartsAt.',
          HttpStatus.BAD_REQUEST,
        );
      }
    }
    if (
      hasSalePrice &&
      typeof dto.price === 'number' &&
      typeof dto.salePrice === 'number' &&
      dto.salePrice >= dto.price
    ) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        'salePrice must be lower than the regular price.',
        HttpStatus.BAD_REQUEST,
      );
    }
  }
}
