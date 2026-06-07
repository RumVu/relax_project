import { HttpStatus, Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import {
  BillingCycle,
  PaymentStatus,
  SubscriptionStatus,
} from '@prisma/client';
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

    const checkoutUrl = this.buildCheckoutUrl({
      paymentId: payment.id,
      planName: plan.name,
      successUrl: dto.successUrl,
      cancelUrl: dto.cancelUrl,
      errorUrl: dto.errorUrl,
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
      checkout: {
        url: checkoutUrl,
        simulated: !providerStatus.configured,
        status: providerStatus.configured
          ? 'READY_TO_REDIRECT'
          : 'SIMULATED_DEV_CHECKOUT',
        note: providerStatus.configured
          ? 'Provider key configured. URL points to simulated page until SDK wired.'
          : 'Simulated checkout (DEV mode). User confirms via /v1/billing/mock-checkout HTML page.',
      },
    };
  }

  private buildCheckoutUrl(params: {
    paymentId: string;
    planName: string;
    successUrl?: string;
    cancelUrl?: string;
    errorUrl?: string;
  }) {
    const base =
      this.configService.get<string>('PUBLIC_BACKEND_URL') ??
      this.configService.get<string>('APP_BASE_URL') ??
      'http://localhost:6823';
    const url = new URL(`${base.replace(/\/$/, '')}/v1/billing/mock-checkout`);
    url.searchParams.set('paymentId', params.paymentId);
    url.searchParams.set('planName', params.planName);
    if (params.successUrl)
      url.searchParams.set('successUrl', params.successUrl);
    if (params.cancelUrl) url.searchParams.set('cancelUrl', params.cancelUrl);
    if (params.errorUrl) url.searchParams.set('errorUrl', params.errorUrl);
    return url.toString();
  }

  async renderMockCheckoutPage(params: {
    paymentId: string;
    planName: string;
    successUrl?: string;
    cancelUrl?: string;
    errorUrl?: string;
  }): Promise<string> {
    const plan = await this.resolvePlan(params.planName);
    const formattedPrice = new Intl.NumberFormat('vi-VN', {
      style: 'currency',
      currency: plan.currency,
    }).format(plan.price);

    const featuresList = plan.features
      .map(
        (f) => `
      <li class="feature-item">
        <span class="feature-icon">
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="3" stroke-linecap="round" stroke-linejoin="round"><polyline points="20 6 9 17 4 12"></polyline></svg>
        </span>
        ${f}
      </li>
    `,
      )
      .join('');

    return `<!DOCTYPE html>
<html lang="vi">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>Thanh toán giả lập - Thi Ái Chill</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Outfit:wght@300;400;500;600;700&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg-gradient: linear-gradient(135deg, #0b0f19 0%, #111827 100%);
      --card-bg: rgba(17, 24, 39, 0.7);
      --border-color: rgba(255, 255, 255, 0.08);
      --accent-color: #8b5cf6;
      --accent-hover: #7c3aed;
      --text-primary: #f3f4f6;
      --text-secondary: #9ca3af;
    }

    * {
      box-sizing: border-box;
      margin: 0;
      padding: 0;
    }

    body {
      font-family: 'Outfit', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
      background: var(--bg-gradient);
      color: var(--text-primary);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 24px;
      overflow-x: hidden;
    }

    .background-glow {
      position: absolute;
      width: 400px;
      height: 400px;
      background: radial-gradient(circle, rgba(139, 92, 246, 0.15) 0%, rgba(139, 92, 246, 0) 70%);
      top: 50%;
      left: 50%;
      transform: translate(-55%, -55%);
      z-index: 0;
      pointer-events: none;
    }

    .checkout-card {
      background: var(--card-bg);
      backdrop-filter: blur(16px);
      -webkit-backdrop-filter: blur(16px);
      border: 1px solid var(--border-color);
      border-radius: 24px;
      width: 100%;
      max-width: 440px;
      padding: 40px;
      box-shadow: 0 20px 40px rgba(0, 0, 0, 0.4);
      z-index: 1;
      animation: fadeIn 0.6s ease-out;
    }

    .brand {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 32px;
    }

    .brand-logo {
      width: 36px;
      height: 36px;
      background: linear-gradient(135deg, var(--accent-color) 0%, #ec4899 100%);
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      font-weight: 700;
      color: white;
      font-size: 20px;
      box-shadow: 0 0 20px rgba(139, 92, 246, 0.4);
    }

    .brand-name {
      font-size: 20px;
      font-weight: 600;
      letter-spacing: -0.5px;
      background: linear-gradient(135deg, #f3f4f6 0%, #9ca3af 100%);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
    }

    .badge {
      display: inline-block;
      padding: 6px 12px;
      background: rgba(139, 92, 246, 0.15);
      border: 1px solid rgba(139, 92, 246, 0.3);
      color: #c084fc;
      border-radius: 100px;
      font-size: 12px;
      font-weight: 500;
      margin-bottom: 24px;
      letter-spacing: 0.5px;
      text-transform: uppercase;
    }

    .plan-title {
      font-size: 32px;
      font-weight: 700;
      margin-bottom: 8px;
      letter-spacing: -0.8px;
    }

    .plan-price {
      font-size: 24px;
      font-weight: 600;
      color: #38bdf8;
      margin-bottom: 24px;
    }

    .divider {
      height: 1px;
      background: var(--border-color);
      margin: 24px 0;
    }

    .features-list {
      list-style: none;
      margin-bottom: 32px;
    }

    .feature-item {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 12px;
      font-size: 15px;
      color: var(--text-secondary);
    }

    .feature-icon {
      color: #34d399;
      display: flex;
      align-items: center;
      justify-content: center;
    }

    .btn {
      width: 100%;
      padding: 16px;
      border-radius: 14px;
      font-family: inherit;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1);
      display: flex;
      align-items: center;
      justify-content: center;
      text-decoration: none;
    }

    .btn-primary {
      background: linear-gradient(135deg, var(--accent-color) 0%, #7c3aed 100%);
      color: white;
      border: none;
      box-shadow: 0 4px 15px rgba(139, 92, 246, 0.3);
      margin-bottom: 12px;
    }

    .btn-primary:hover {
      transform: translateY(-2px);
      box-shadow: 0 6px 20px rgba(139, 92, 246, 0.45), 0 0 0 2px rgba(139, 92, 246, 0.2);
    }

    .btn-primary:active {
      transform: translateY(0);
    }

    .btn-secondary {
      background: transparent;
      color: var(--text-secondary);
      border: 1px solid var(--border-color);
    }

    .btn-secondary:hover {
      background: rgba(255, 255, 255, 0.03);
      color: var(--text-primary);
    }

    .loading-spinner {
      display: none;
      width: 20px;
      height: 20px;
      border: 3px solid rgba(255, 255, 255, 0.3);
      border-radius: 50%;
      border-top-color: white;
      animation: spin 0.8s linear infinite;
      margin-left: 8px;
    }

    @keyframes spin {
      to { transform: rotate(360deg); }
    }

    @keyframes fadeIn {
      from { opacity: 0; transform: translateY(16px); }
      to { opacity: 1; transform: translateY(0); }
    }

    .dev-badge {
      background: #f59e0b;
      color: #1e1b4b;
      font-size: 11px;
      font-weight: 700;
      padding: 2px 6px;
      border-radius: 4px;
      margin-left: 8px;
      vertical-align: middle;
    }
  </style>
</head>
<body>
  <div class="background-glow"></div>
  <div class="checkout-card">
    <div class="brand">
      <div class="brand-logo">✦</div>
      <div class="brand-name">Thi Ái Chill <span class="dev-badge">DEV</span></div>
    </div>
    
    <div class="badge">Simulated Checkout</div>
    <h1 class="plan-title">${plan.title}</h1>
    <div class="plan-price">${formattedPrice}</div>
    
    <div class="divider"></div>
    
    <ul class="features-list">
      ${featuresList}
    </ul>
    
    <button id="pay-btn" class="btn btn-primary" onclick="handlePayment()">
      <span>Xác nhận thanh toán</span>
      <div id="spinner" class="loading-spinner"></div>
    </button>
    
    <a href="${params.cancelUrl || '#'}" class="btn btn-secondary">Quay lại</a>
  </div>

  <script>
    async function handlePayment() {
      const payBtn = document.getElementById('pay-btn');
      const spinner = document.getElementById('spinner');
      const btnText = payBtn.querySelector('span');
      
      payBtn.disabled = true;
      spinner.style.display = 'block';
      btnText.textContent = 'Đang xử lý...';

      const paymentId = "${params.paymentId}";
      const planName = "${params.planName}";
      const successUrl = ${params.successUrl ? `"${params.successUrl}"` : 'undefined'};
      const errorUrl = ${params.errorUrl ? `"${params.errorUrl}"` : 'undefined'};

      try {
        const response = await fetch('/v1/billing/mock-checkout/settle', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json'
          },
          body: JSON.stringify({ paymentId, planName, successUrl, errorUrl })
        });

        if (response.redirected) {
          window.location.href = response.url;
        } else if (response.ok) {
          if (successUrl) {
            window.location.href = successUrl;
          } else {
            alert('Thanh toán thành công!');
          }
        } else {
          const err = await response.json();
          alert('Lỗi thanh toán: ' + (err.message || 'Không rõ nguyên nhân'));
          if (errorUrl) {
            window.location.href = errorUrl;
          }
        }
      } catch (error) {
        alert('Lỗi kết nối: ' + error.message);
        if (errorUrl) {
          window.location.href = errorUrl;
        }
      } finally {
        payBtn.disabled = false;
        spinner.style.display = 'none';
        btnText.textContent = 'Xác nhận thanh toán';
      }
    }
  </script>
</body>
</html>`;
  }

  async settleMockCheckout(paymentId: string, planName: string) {
    const payment = await this.prisma.payment.findUnique({
      where: { id: paymentId },
    });
    if (!payment) {
      throw new AppException(
        ErrorCode.PAYMENT_NOT_FOUND,
        'Payment not found',
        HttpStatus.NOT_FOUND,
      );
    }
    return this.confirmPayment(payment.userId, payment.id, { planName });
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
      const fullTier = await this.prisma.subscriptionTier.findUnique({
        where: { id: tier.id },
        include: { features: { orderBy: { name: 'asc' } } },
      });
      const features =
        fullTier?.features
          .filter((feature) => feature.included)
          .map((feature) => feature.description ?? feature.name) ?? [];

      return {
        source: 'subscription_tier' as const,
        tier,
        name: tier.name,
        title: this.toPlanTitle(tier.name),
        price: tier.price,
        currency: tier.currency,
        features,
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
        features: fallback.features,
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
