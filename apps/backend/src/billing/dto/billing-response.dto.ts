import { ApiProperty } from '@nestjs/swagger';
import { PaymentStatus, SubscriptionStatus } from '@prisma/client';

export class SubscriptionResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty() userId!: string;
  @ApiProperty({ nullable: true }) tierId!: string | null;
  @ApiProperty({ enum: SubscriptionStatus }) status!: SubscriptionStatus;
  @ApiProperty() planName!: string;
  @ApiProperty({ type: 'integer' }) price!: number;
  @ApiProperty() currency!: string;
  @ApiProperty({ type: 'string', format: 'date-time' }) startDate!: Date;
  @ApiProperty({ nullable: true, type: 'string', format: 'date-time' })
  endDate!: Date | null;
  @ApiProperty({ nullable: true }) externalSubscriptionId!: string | null;
  @ApiProperty({ type: 'string', format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: 'string', format: 'date-time' }) updatedAt!: Date;
}

export class PaymentResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty() userId!: string;
  @ApiProperty({ type: 'integer' }) amount!: number;
  @ApiProperty() currency!: string;
  @ApiProperty({ enum: PaymentStatus }) status!: PaymentStatus;
  @ApiProperty({ nullable: true }) provider!: string | null;
  @ApiProperty({ nullable: true }) method!: string | null;
  @ApiProperty({ nullable: true }) description!: string | null;
  @ApiProperty({ type: 'string', format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: 'string', format: 'date-time' }) updatedAt!: Date;
}

export class ConfirmPaymentPlanDto {
  @ApiProperty() name!: string;
  @ApiProperty() title!: string;
  @ApiProperty({ type: 'integer' }) price!: number;
  @ApiProperty() currency!: string;
  @ApiProperty() source!: string;
}

export class ConfirmPaymentResponseDto {
  @ApiProperty({ type: () => PaymentResponseDto }) payment!: PaymentResponseDto;
  @ApiProperty({ type: () => SubscriptionResponseDto })
  subscription!: SubscriptionResponseDto;
  @ApiProperty({ type: () => ConfirmPaymentPlanDto })
  plan!: ConfirmPaymentPlanDto;
}
