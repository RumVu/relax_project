import { IsString, MinLength } from 'class-validator';

export class ConfirmPaymentDto {
  /**
   * Plan the pending payment was created for. The backend re-resolves the
   * plan from SubscriptionTier/fallback catalog and verifies the paid amount
   * matches before activating the subscription.
   */
  @IsString()
  @MinLength(1)
  planName!: string;
}
