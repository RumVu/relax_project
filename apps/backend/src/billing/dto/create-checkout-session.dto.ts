import {
  IsIn,
  IsNumber,
  IsOptional,
  IsString,
  IsUrl,
  MaxLength,
  Min,
} from 'class-validator';

export class CreateCheckoutSessionDto {
  @IsString()
  @MaxLength(100)
  planName!: string;

  @IsOptional()
  @IsNumber()
  @Min(0)
  amount?: number;

  @IsOptional()
  @IsString()
  @MaxLength(10)
  currency?: string;

  @IsOptional()
  @IsString()
  @IsIn(['STRIPE', 'APP_STORE', 'GOOGLE_PLAY', 'SEPAY'])
  provider?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;

  @IsOptional()
  @IsUrl({ require_tld: false }, { message: 'successUrl must be a valid URL' })
  @MaxLength(2048)
  successUrl?: string;

  @IsOptional()
  @IsUrl({ require_tld: false }, { message: 'errorUrl must be a valid URL' })
  @MaxLength(2048)
  errorUrl?: string;

  @IsOptional()
  @IsUrl({ require_tld: false }, { message: 'cancelUrl must be a valid URL' })
  @MaxLength(2048)
  cancelUrl?: string;
}
