import { HttpStatus, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  BillingCycle,
  PaymentStatus,
  SubscriptionStatus,
} from '@prisma/client';
import { SePayPgClient } from 'sepay-pg-node';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { UsersService } from '../users/users.service';
import { ConfirmPaymentDto } from './dto/confirm-payment.dto';
import { CreateCheckoutSessionDto } from './dto/create-checkout-session.dto';

const MONTHLY_PERIOD_DAYS = 30;
const ANNUAL_PERIOD_DAYS = 365;
const DEFAULT_ALLOWED_REDIRECT_ORIGINS = [
  'http://localhost:3233',
  'http://localhost:3000',
  'https://relax-project-web-dashboard.vercel.app',
];

// Một pending payment được coi là "đang chờ chuyển khoản" trong 30 phút —
// đủ thời gian để user quét QR, mở app ngân hàng, xác thực OTP. Sau ngưỡng
// này nó bị đánh FAILED để (a) dọn rác lịch sử thanh toán, (b) tránh
// amount-fallback của webhook SePay bị ambiguous.
const PENDING_PAYMENT_TTL_MS = 30 * 60 * 1000;

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
    const sepayConfigured =
      Boolean(this.configService.get<string>('SEPAY_MERCHANT_ID')) &&
      Boolean(this.configService.get<string>('SEPAY_SECRET_KEY')) &&
      Boolean(this.configService.get<string>('SEPAY_WEBHOOK_API_KEY'));

    return {
      configured:
        stripeConfigured ||
        appStoreConfigured ||
        googlePlayConfigured ||
        sepayConfigured,
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
        SEPAY: {
          configured: sepayConfigured,
          missingKeys: this.missingKeys([
            ['SEPAY_MERCHANT_ID', this.configService.get('SEPAY_MERCHANT_ID')],
            ['SEPAY_SECRET_KEY', this.configService.get('SEPAY_SECRET_KEY')],
            [
              'SEPAY_WEBHOOK_API_KEY',
              this.configService.get('SEPAY_WEBHOOK_API_KEY'),
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
      const now = new Date();
      return tiers.map((tier) => {
        const onSale = this.isOnSale(tier, now);
        const effectivePrice =
          onSale && tier.salePrice != null ? tier.salePrice : tier.price;
        return {
          id: tier.id,
          name: tier.name,
          title: tier.title ?? this.toPlanTitle(tier.name),
          description: tier.description,
          price: tier.price,
          /** Discounted price when active; same as price otherwise. UI should bind this. */
          effectivePrice,
          sale: onSale
            ? {
                price: tier.salePrice,
                label: tier.saleLabel,
                startsAt: tier.saleStartsAt,
                endsAt: tier.saleEndsAt,
                percentOff:
                  tier.price > 0 && tier.salePrice != null
                    ? Math.round(
                        ((tier.price - tier.salePrice) / tier.price) * 100,
                      )
                    : 0,
              }
            : null,
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
        };
      });
    }

    return this.getFallbackPlans();
  }

  /** True when `now` is inside [saleStartsAt, saleEndsAt] and salePrice is set. */
  private isOnSale(
    tier: {
      salePrice: number | null;
      saleStartsAt: Date | null;
      saleEndsAt: Date | null;
    },
    now: Date,
  ): boolean {
    if (tier.salePrice == null) return false;
    if (!tier.saleStartsAt || !tier.saleEndsAt) return false;
    return now >= tier.saleStartsAt && now <= tier.saleEndsAt;
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
    const planAmount = this.toPaymentAmount(plan.price);

    // 1) Đánh FAILED mọi pending payment quá hạn của user — dọn rác lịch sử
    //    và tránh amount-fallback webhook bị ambiguous.
    const ttlCutoff = new Date(Date.now() - PENDING_PAYMENT_TTL_MS);
    await this.prisma.payment.updateMany({
      where: {
        userId,
        status: PaymentStatus.PENDING,
        createdAt: { lt: ttlCutoff },
      },
      data: { status: PaymentStatus.FAILED },
    });

    // 2) Reuse pending payment còn hạn cùng user/plan/provider — tránh tạo
    //    duplicate khi user double-click hoặc reload trang checkout.
    const reusable = await this.prisma.payment.findFirst({
      where: {
        userId,
        status: PaymentStatus.PENDING,
        provider,
        amount: planAmount,
        createdAt: { gte: ttlCutoff },
      },
      orderBy: { createdAt: 'desc' },
    });

    const payment =
      reusable ??
      (await this.prisma.payment.create({
        data: {
          userId,
          amount: planAmount,
          currency: plan.currency,
          status: PaymentStatus.PENDING,
          provider,
          description: dto.description ?? `Upgrade to ${plan.title}`,
        },
      }));

    if (provider === 'SEPAY') {
      const merchantId = this.configService.get<string>('SEPAY_MERCHANT_ID');
      const secretKey = this.configService.get<string>('SEPAY_SECRET_KEY');
      const env = this.configService.get<string>('SEPAY_ENV') || 'sandbox';
      const sepayConfigured =
        Boolean(merchantId) &&
        Boolean(secretKey) &&
        Boolean(this.configService.get<string>('SEPAY_WEBHOOK_API_KEY'));

      const bankId = (
        this.configService.get<string>('ADMIN_BANK_ID') || 'MB'
      ).trim();
      const accountNo = (
        this.configService.get<string>('ADMIN_BANK_ACCOUNT') || '0969966969'
      ).trim();
      const accountName = (
        this.configService.get<string>('ADMIN_BANK_HOLDER') || 'NGUYEN VAN A'
      ).trim();
      const bankName = (
        this.configService.get<string>('ADMIN_BANK_NAME') || 'MB Bank'
      ).trim();
      const transferContent = `RELAX${payment.id}`;
      const amount = planAmount;
      const qrUrl = `https://img.vietqr.io/image/${bankId}-${accountNo}-compact.png?amount=${amount}&addInfo=${transferContent}&accountName=${encodeURIComponent(accountName)}`;

      if (!sepayConfigured) {
        // Trước đây throw 500 → dashboard fail tất cả checkout. Fix: fallback
        // sang MANUAL silently — backend trả response shape không có
        // checkoutUrl, dashboard sẽ rơi vào Path B (auto-confirm endpoint)
        // để activate plan ngay. Đây là dev/staging mode, hợp lý vì SEPAY
        // env chỉ có production. Frontend nhận `configured:false +
        // simulated:true` để optionally hiển thị banner "DEV mode".
        return {
          configured: false,
          provider: 'MANUAL',
          tier: plan.tier,
          plan: {
            name: plan.name,
            title: plan.title,
            price: plan.price,
            currency: plan.currency,
            source: plan.source,
          },
          payment,
          checkout: {
            status: 'SEPAY_NOT_CONFIGURED_FALLBACK_MANUAL',
            note: 'SePay chưa cấu hình production env. Backend fallback MANUAL — dashboard sẽ auto-activate qua /confirm endpoint.',
            simulated: true,
            amount,
            qrCodeUrl: qrUrl,
            qrUrl,
            transferContent,
            bankId,
            bankName,
            accountNo,
            bankAccount: accountNo,
            accountName,
            paymentId: payment.id,
          },
        };
      }

      const client = new SePayPgClient({
        env: env as 'sandbox' | 'production',
        merchant_id: merchantId!,
        secret_key: secretKey!,
      });

      const checkoutURL = client.checkout.initCheckoutUrl();

      const defaultBase =
        this.configService.get<string>('WEB_APP_URL') ||
        'http://localhost:3233';
      const successUrl = this.validateRedirectUrl(
        dto.successUrl,
        `${defaultBase}/billing?status=success`,
      );
      const errorUrl = this.validateRedirectUrl(
        dto.errorUrl,
        `${defaultBase}/billing?status=error`,
      );
      const cancelUrl = this.validateRedirectUrl(
        dto.cancelUrl,
        `${defaultBase}/billing?status=cancel`,
      );

      const checkoutFormfields = client.checkout.initOneTimePaymentFields({
        payment_method: 'BANK_TRANSFER',
        order_invoice_number: payment.id,
        order_amount: amount,
        currency: plan.currency || 'VND',
        order_description:
          dto.description ?? `Thanh toan nang cap tai khoan ${plan.title}`,
        success_url: successUrl,
        error_url: errorUrl,
        cancel_url: cancelUrl,
      });

      return {
        configured: true,
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
        checkout: {
          status: 'READY',
          note: 'Hãy gửi POST request tới checkoutUrl với các thông tin trong checkoutFormfields để thực hiện thanh toán.',
          checkoutUrl: checkoutURL,
          checkoutFormfields,
          amount,
          qrCodeUrl: qrUrl,
          qrUrl,
          transferContent,
          bankId,
          bankName,
          accountNo,
          bankAccount: accountNo,
          accountName,
          paymentId: payment.id,
        },
      };
    }

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
    isAdminOrWebhook = false,
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

    if (!isAdminOrWebhook) {
      throw new AppException(
        ErrorCode.AUTH_FORBIDDEN,
        'Chỉ admin hoặc webhook mới có thể xác nhận thanh toán.',
        HttpStatus.FORBIDDEN,
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
      const locked = await tx.payment.findFirst({
        where: { id: payment.id, status: PaymentStatus.PENDING },
      });
      if (!locked) {
        throw new AppException(
          ErrorCode.PAYMENT_NOT_PENDING,
          'Only a pending payment can be confirmed',
          HttpStatus.CONFLICT,
        );
      }

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
      // Apply sale price if currently in the sale window — so checkout
      // shows the discounted total and the webhook matches that amount.
      const now = new Date();
      const onSale = this.isOnSale(tier, now);
      const effectivePrice =
        onSale && tier.salePrice != null ? tier.salePrice : tier.price;
      return {
        source: 'subscription_tier' as const,
        tier,
        name: tier.name,
        title: tier.title ?? this.toPlanTitle(tier.name),
        price: effectivePrice,
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

  async resolvePlanByAmount(amount: number) {
    const tiers = await this.prisma.subscriptionTier.findMany({
      where: { isActive: true },
    });
    const now = new Date();
    // Match against sale price when active, else list price.
    const tier = tiers.find((t) => {
      const onSale = this.isOnSale(t, now);
      const effective = onSale && t.salePrice != null ? t.salePrice : t.price;
      return this.toPaymentAmount(effective) === amount;
    });
    if (tier) {
      const onSale = this.isOnSale(tier, now);
      const effectivePrice =
        onSale && tier.salePrice != null ? tier.salePrice : tier.price;
      return {
        source: 'subscription_tier' as const,
        tier,
        name: tier.name,
        title: tier.title ?? this.toPlanTitle(tier.name),
        price: effectivePrice,
        currency: tier.currency,
      };
    }

    const fallback = this.getFallbackPlans().find(
      (plan) => this.toPaymentAmount(plan.price) === amount,
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
      `No active subscription plan found with price ${amount}`,
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

  async downgrade(userId: string, planName: string) {
    await this.usersService.findOne(userId);
    const plan = await this.resolvePlan(planName);

    if (plan.price !== 0) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        'Only free plans can be downgraded to without payment',
        HttpStatus.BAD_REQUEST,
      );
    }

    const startDate = new Date();

    const subscription = await this.prisma.$transaction(async (tx) => {
      await tx.subscription.updateMany({
        where: { userId, status: SubscriptionStatus.ACTIVE },
        data: { status: SubscriptionStatus.CANCELLED, endDate: startDate },
      });

      return tx.subscription.create({
        data: {
          userId,
          tierId: plan.tier?.id ?? null,
          status: SubscriptionStatus.ACTIVE,
          planName: plan.name,
          price: 0,
          currency: plan.currency,
          startDate,
        },
      });
    });

    return {
      subscription,
      plan: {
        name: plan.name,
        title: plan.title,
        price: plan.price,
        currency: plan.currency,
      },
    };
  }

  async getMyPayments(userId: string) {
    await this.usersService.findOne(userId);
    return this.prisma.payment.findMany({
      where: { userId },
      orderBy: { createdAt: 'desc' },
    });
  }

  async getPayment(userId: string, id: string) {
    await this.usersService.findOne(userId);
    const payment = await this.prisma.payment.findUnique({
      where: { id },
    });
    if (!payment || payment.userId !== userId) {
      throw new AppException(
        ErrorCode.PAYMENT_NOT_FOUND,
        'Payment not found',
        HttpStatus.NOT_FOUND,
      );
    }
    return payment;
  }

  private validateRedirectUrl(
    url: string | undefined,
    fallback: string,
  ): string {
    if (!url) return fallback;
    try {
      const parsed = new URL(url);
      const allowedCsv = this.configService.get<string>(
        'CHECKOUT_ALLOWED_ORIGINS',
      );
      const allowed = allowedCsv
        ? allowedCsv.split(',').map((o) => o.trim())
        : DEFAULT_ALLOWED_REDIRECT_ORIGINS;
      if (allowed.includes(parsed.origin)) return url;
    } catch {
      // invalid URL
    }
    return fallback;
  }

  private toPaymentAmount(value: number) {
    return Math.round(value);
  }
}
