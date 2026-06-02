import { BillingCycle } from '@prisma/client';
import { SubscriptionResponseDto } from './billing-response.dto';

/**
 * Shared shape for provider readiness endpoints (`/v1/billing/providers`,
 * `/v1/notifications/providers`). Per-provider entries are loose-typed because
 * each provider exposes different missing-key sets and notes.
 */
export class ProviderStatusResponseDto {
  configured!: boolean;
  providers!: Record<string, unknown>;
}

export class BillingPlanLimitDto {
  name!: string;
  value!: number;
  unit!: string | null;
}

export class BillingPlanResponseDto {
  id?: string;
  name!: string;
  title!: string;
  description?: string | null;
  price!: number;
  currency!: string;
  billingCycle?: BillingCycle;
  features!: string[];
  limits?: BillingPlanLimitDto[];
}

/**
 * Minimal synthetic subscription returned by `/v1/billing/me` when the user
 * has never purchased anything; it does not include all Subscription fields.
 */
export class SyntheticFreeSubscriptionDto {
  userId!: string;
  status!: string;
  planName!: string;
  price!: number;
  currency!: string;
}

export class BillingMeResponseDto {
  /**
   * Either the latest real Subscription row or a synthetic FREE placeholder.
   */
  subscription!: SubscriptionResponseDto | SyntheticFreeSubscriptionDto;
  providerStatus!: ProviderStatusResponseDto;
}

export class CheckoutResolvedPlanDto {
  name!: string;
  title!: string;
  price!: number;
  currency!: string;
  source!: string;
}

export class CheckoutSessionStatusDto {
  status!: string;
  note!: string;
  qrCodeUrl?: string;
  transferContent?: string;
  bankId?: string;
  accountNo?: string;
  accountName?: string;
  amount?: number;
  checkoutUrl?: string;
  checkoutFormfields?: Record<string, string>;
}

export class CheckoutSessionResponseDto {
  configured!: boolean;
  provider!: string;
  /** Raw SubscriptionTier row when the plan came from the DB, else null. */
  tier!: unknown;
  plan!: CheckoutResolvedPlanDto;
  payment!: unknown;
  checkout!: CheckoutSessionStatusDto;
}
