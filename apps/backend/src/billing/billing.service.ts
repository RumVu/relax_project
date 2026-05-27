import { HttpStatus, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { BillingCycle, PaymentStatus, SubscriptionStatus } from '@prisma/client';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { ConfirmPaymentDto } from './dto/confirm-payment.dto';
import { CreateCheckoutSessionDto } from './dto/create-checkout-session.dto';

const MONTHLY_PERIOD_DAYS = 30;
const ANNUAL_PERIOD_DAYS = 365;

@Injectable()
export class BillingService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly usersService: UsersService,
    private readonly configService: ConfigService,
  ) {}

  getProviderStatus() {
    const stripeConfigured = Boolean(
      this.configService.get<string>('STRIPE_SECRET_KEY'),
    );
    const appStoreConfigured =
      Boolean(this.configService.get<string>('APPLE_SHARED_SECRET')) ||
      Boolean(this.configService.get<string>('APP_STORE_CONNECT_API_KEY'));
    const googlePlayConfigured = Boolean(
      this.configService.get<string>('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON'),
    );

    return {
      configured:
        stripeConfigured || appStoreConfigured || googlePlayConfigured,
      providers: {
        STRIPE: {
          configured: stripeConfigured,
          missingKeys: this.missingKeys([
            ['STRIPE_SECRET_KEY', this.configService.get('STRIPE_SECRET_KEY')],
          ]),
        },
        APP_STORE: {
          configured: appStoreConfigured,
          missingKeys: this.missingKeys([
            [
              'APPLE_SHARED_SECRET',
              this.configService.get('APPLE_SHARED_SECRET'),
            ],
            [
              'APP_STORE_CONNECT_API_KEY',
              this.configService.get('APP_STORE_CONNECT_API_KEY'),
            ],
          ]),
          note: 'App Store chỉ cần một trong các cấu hình receipt validation.',
        },
        GOOGLE_PLAY: {
          configured: googlePlayConfigured,
          missingKeys: this.missingKeys([
            [
              'GOOGLE_PLAY_SERVICE_ACCOUNT_JSON',
              this.configService.get('GOOGLE_PLAY_SERVICE_ACCOUNT_JSON'),
            ],
          ]),
        },
      },
    };
  }

  async getPlans() {
    const tiers = await this.prisma.subscriptionTier.findMany({
      where: { isActive: true },
      include: {
        features: { orderBy: { name: 'asc' } },
        limits: { orderBy: { name: 'asc' } },
      },
      orderBy: [{ displayOrder: 'asc' }, { price: 'asc' }],
    });

    if (tiers.length > 0) {
      return tiers.map((tier) => ({
        id: tier.id,
        name: tier.name,
        title: this.toPlanTitle(tier.name),
        description: tier.description,
        price: tier.price,
        currency: tier.currency,
        billingCycle: tier.billingCycle,
        features: tier.features
          .filter((feature) => feature.included)
          .map((feature) => feature.description ?? feature.name),
        limits: tier.limits.map((limit) => ({
          name: limit.name,
          value: limit.value,
          unit: limit.unit,
        })),
      }));
    }

    return this.getFallbackPlans();
  }

  async getMine(userId: string) {
    await this.usersService.findOne(userId);
    const subscription = await this.prisma.subscription.findFirst({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });

    return {
      subscription:
        subscription ??
        ({
          userId,
          status: SubscriptionStatus.ACTIVE,
          planName: 'FREE',
          price: 0,
          currency: 'VND',
        } as const),
      providerStatus: this.getProviderStatus(),
    };
  }

  async createCheckoutSession(userId: string, dto: CreateCheckoutSessionDto) {
    await this.usersService.findOne(userId);
    const provider = dto.provider ?? 'MANUAL';
    const providerStatus = this.getProviderStatus();
    const plan = await this.resolvePlan(dto.planName);
    const payment = await this.prisma.payment.create({
      data: {
        userId,
        amount: this.toPaymentAmount(plan.price),
        currency: plan.currency,
        status: PaymentStatus.PENDING,
        provider,
        description: dto.description ?? `Upgrade to ${plan.title}`,
      },
    });

    return {
      configured: providerStatus.configured,
      provider,
      tier: plan.tier,
      plan: {
        name: plan.name,
        title: plan.title,
        price: plan.price,
        currency: plan.currency,
        source: plan.source,
      },
      payment,
      checkout: providerStatus.configured
        ? {
            status: 'READY_TO_CREATE_PROVIDER_SESSION',
            note: 'Provider key is configured; wire SDK session creation here.',
          }
        : {
            status: 'PROVIDER_NOT_CONFIGURED',
            note: 'Backend đã tạo payment pending. Cần cấu hình Stripe/App Store/Google Play để lấy checkout URL thật.',
          },
    };
  }

  /**
   * Activates a subscription once its pending payment is settled. This is the
   * provider-agnostic settlement step: a real Stripe/App Store/Google Play
   * webhook would call the same logic after verifying the provider event,
   * while the manual/dev flow calls it directly. It flips the payment to
   * COMPLETED and provisions an ACTIVE subscription for the resolved plan.
   */
  async confirmPayment(
    userId: string,
    paymentId: string,
    dto: ConfirmPaymentDto,
  ) {
    await this.usersService.findOne(userId);

    const payment = await this.prisma.payment.findUnique({
      where: { id: paymentId },
    });
    if (!payment || payment.userId !== userId) {
      throw new AppException(
        ErrorCode.PAYMENT_NOT_FOUND,
        'Payment not found',
        HttpStatus.NOT_FOUND,
      );
    }
    if (payment.status !== PaymentStatus.PENDING) {
      throw new AppException(
        ErrorCode.PAYMENT_NOT_PENDING,
        'Only a pending payment can be confirmed',
        HttpStatus.CONFLICT,
      );
    }

    const plan = await this.resolvePlan(dto.planName);
    if (this.toPaymentAmount(plan.price) !== payment.amount) {
      throw new AppException(
        ErrorCode.PAYMENT_PLAN_MISMATCH,
        'Paid amount does not match the requested plan price',
        HttpStatus.BAD_REQUEST,
      );
    }

    const startDate = new Date();
    const endDate = this.computePeriodEnd(startDate, plan.tier?.billingCycle);

    const result = await this.prisma.$transaction(async (tx) => {
      const updatedPayment = await tx.payment.update({
        where: { id: payment.id },
        data: { status: PaymentStatus.COMPLETED },
      });

      // Close out any currently active subscription before provisioning the
      // new one so getMine() always reflects the latest plan.
      await tx.subscription.updateMany({
        where: { userId, status: SubscriptionStatus.ACTIVE },
        data: { status: SubscriptionStatus.CANCELLED, endDate: startDate },
      });

      const subscription = await tx.subscription.create({
        data: {
          userId,
          tierId: plan.tier?.id ?? null,
          status: SubscriptionStatus.ACTIVE,
          planName: plan.name,
          price: plan.price,
          currency: plan.currency,
          startDate,
          endDate,
        },
      });

      return { payment: updatedPayment, subscription };
    });

    return {
      payment: result.payment,
      subscription: result.subscription,
      plan: {
        name: plan.name,
        title: plan.title,
        price: plan.price,
        currency: plan.currency,
        source: plan.source,
      },
    };
  }

  private computePeriodEnd(start: Date, billingCycle?: BillingCycle) {
    const end = new Date(start);
    const days =
      billingCycle === BillingCycle.ANNUAL
        ? ANNUAL_PERIOD_DAYS
        : MONTHLY_PERIOD_DAYS;
    end.setDate(end.getDate() + days);
    return end;
  }

  private missingKeys(keys: Array<[string, string | undefined]>) {
    return keys.filter(([, value]) => !value).map(([key]) => key);
  }

  private async findTierByPlanName(planName: string) {
    const tiers = await this.prisma.subscriptionTier.findMany({
      where: { isActive: true },
    });
    const normalizedPlanName = this.normalizePlanName(planName);

    return (
      tiers.find(
        (tier) =>
          this.normalizePlanName(tier.name) === normalizedPlanName ||
          this.normalizePlanName(this.toPlanTitle(tier.name)) ===
            normalizedPlanName,
      ) ?? null
    );
  }

  private async resolvePlan(planName: string) {
    const tier = await this.findTierByPlanName(planName);
    if (tier) {
      return {
        source: 'subscription_tier' as const,
        tier,
        name: tier.name,
        title: this.toPlanTitle(tier.name),
        price: tier.price,
        currency: tier.currency,
      };
    }

    const fallback = this.getFallbackPlans().find(
      (plan) =>
        this.normalizePlanName(plan.name) ===
          this.normalizePlanName(planName) ||
        this.normalizePlanName(plan.title) === this.normalizePlanName(planName),
    );

    if (fallback) {
      return {
        source: 'fallback_catalog' as const,
        tier: null,
        name: fallback.name,
        title: fallback.title,
        price: fallback.price,
        currency: fallback.currency,
      };
    }

    throw new AppException(
      ErrorCode.VALIDATION_FAILED,
      'Subscription plan is not available',
      HttpStatus.BAD_REQUEST,
    );
  }

  private getFallbackPlans() {
    return [
      {
        name: 'FREE',
        title: 'Miễn phí',
        price: 0,
        currency: 'VND',
        features: ['Mood check-in', 'Journal cơ bản', 'Companion mặc định'],
      },
      {
        name: 'CHILL_PLUS',
        title: 'Chill Plus',
        price: 49000,
        currency: 'VND',
        features: [
          'Thống kê nâng cao',
          'Companion custom',
          'Kho âm thanh mở rộng',
          'Reminder thông minh',
        ],
      },
    ];
  }

  private normalizePlanName(value: string) {
    return value
      .replace(/[_-]+/g, ' ')
      .replace(/\s+/g, ' ')
      .trim()
      .toLowerCase();
  }

  private toPlanTitle(name: string) {
    return name
      .toLowerCase()
      .split('_')
      .map((part) => part.charAt(0).toUpperCase() + part.slice(1))
      .join(' ');
  }

  private toPaymentAmount(value: number) {
    return Math.round(value);
  }
}
