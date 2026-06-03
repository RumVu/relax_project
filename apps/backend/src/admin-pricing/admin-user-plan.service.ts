import {
  HttpStatus,
  Injectable,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { BillingCycle, SubscriptionStatus } from '@prisma/client';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';

const MONTHLY_PERIOD_DAYS = 30;
const ANNUAL_PERIOD_DAYS = 365;

/**
 * Admin-side direct plan provisioning. Bypasses the payment flow on
 * purpose — the use case is "I refunded this user out-of-band, give them
 * CHILL_PLUS for a month" or "this is a test account, leave it on FREE".
 *
 * Mirrors the bookkeeping that BillingService.confirmPayment does after
 * a successful payment so the rest of the app sees a normal subscription.
 */
@Injectable()
export class AdminUserPlanService {
  private readonly logger = new Logger(AdminUserPlanService.name);
  constructor(private readonly prisma: PrismaService) {}

  async getCurrent(userId: string) {
    await this.requireUser(userId);
    const subscription = await this.prisma.subscription.findFirst({
      where: { userId, status: SubscriptionStatus.ACTIVE },
      orderBy: { startDate: 'desc' },
      include: { tier: true },
    });
    return {
      userId,
      subscription:
        subscription ??
        ({ planName: 'FREE', status: 'ACTIVE', price: 0, currency: 'VND' } as const),
    };
  }

  async setUserPlan(userId: string, planName: string) {
    await this.requireUser(userId);
    const tier = await this.prisma.subscriptionTier.findFirst({
      where: { name: planName },
    });
    if (!tier) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        `Plan ${planName} not found in subscription_tiers. Create the tier first.`,
        HttpStatus.BAD_REQUEST,
      );
    }

    const startDate = new Date();
    const endDate = this.computePeriodEnd(startDate, tier.billingCycle);

    const result = await this.prisma.$transaction(async (tx) => {
      await tx.subscription.updateMany({
        where: { userId, status: SubscriptionStatus.ACTIVE },
        data: { status: SubscriptionStatus.CANCELLED, endDate: startDate },
      });
      return tx.subscription.create({
        data: {
          userId,
          tierId: tier.id,
          status: SubscriptionStatus.ACTIVE,
          planName: tier.name,
          price: tier.price,
          currency: tier.currency,
          startDate,
          endDate,
        },
      });
    });

    this.logger.log(
      `Admin set plan for ${userId}: ${tier.name} (${tier.billingCycle}) until ${endDate?.toISOString() ?? '∞'}`,
    );

    return {
      userId,
      planName: tier.name,
      subscription: result,
    };
  }

  private async requireUser(userId: string) {
    const user = await this.prisma.user.findUnique({
      where: { id: userId },
      select: { id: true, email: true },
    });
    if (!user) {
      throw new NotFoundException({
        code: ErrorCode.USER_NOT_FOUND,
        message: `User ${userId} not found`,
      });
    }
    return user;
  }

  private computePeriodEnd(start: Date, cycle: BillingCycle | null): Date | null {
    if (cycle == null) return null;
    // Schema only enumerates MONTHLY / ANNUAL today. Free tier still goes
    // through here and gets a MONTHLY rollover by default — that's
    // intentional, so we keep a renewal date for streak/limits logic.
    const days = cycle === 'ANNUAL' ? ANNUAL_PERIOD_DAYS : MONTHLY_PERIOD_DAYS;
    const d = new Date(start);
    d.setUTCDate(d.getUTCDate() + days);
    return d;
  }
}
