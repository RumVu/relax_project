import { IsIn, IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class CreateCheckoutSessionDto {
  @IsString()
  planName!: string;

  /**
   * Deprecated compatibility field. The backend always prices from
   * SubscriptionTier/fallback plan catalog and ignores client-provided amount.
   */
  @IsOptional()
  @IsNumber()
  @Min(0)
  amount?: number;

  /**
   * Deprecated compatibility field. The backend always uses the server-side
   * plan currency.
   */
  @IsOptional()
  @IsString()
  currency?: string;

  @IsOptional()
  @IsString()
  @IsIn(['STRIPE', 'APP_STORE', 'GOOGLE_PLAY', 'MANUAL'])
  provider?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  successUrl?: string;

  @IsOptional()
  @IsString()
  cancelUrl?: string;

  @IsOptional()
  @IsString()
  errorUrl?: string;
}
