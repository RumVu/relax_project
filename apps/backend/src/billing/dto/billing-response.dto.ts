import { PaymentStatus, SubscriptionStatus } from '@prisma/client';

export class SubscriptionResponseDto {
  id!: string;
  userId!: string;
  tierId!: string | null;
  status!: SubscriptionStatus;
  planName!: string;
  price!: number;
  currency!: string;
  startDate!: Date;
  endDate!: Date | null;
  externalSubscriptionId!: string | null;
  createdAt!: Date;
  updatedAt!: Date;
}

export class PaymentResponseDto {
  id!: string;
  userId!: string;
  amount!: number;
  currency!: string;
  status!: PaymentStatus;
  provider!: string | null;
  method!: string | null;
  description!: string | null;
  createdAt!: Date;
  updatedAt!: Date;
}

export class ConfirmPaymentPlanDto {
  name!: string;
  title!: string;
  price!: number;
  currency!: string;
  source!: string;
}

export class ConfirmPaymentResponseDto {
  payment!: PaymentResponseDto;
  subscription!: SubscriptionResponseDto;
  plan!: ConfirmPaymentPlanDto;
}
