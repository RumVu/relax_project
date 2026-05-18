import { IsNumber, IsOptional, IsString, Min } from 'class-validator';

export class CreateCheckoutSessionDto {
  @IsString()
  planName!: string;

  @IsNumber()
  @Min(0)
  amount!: number;

  @IsOptional()
  @IsString()
  currency?: string;

  @IsOptional()
  @IsString()
  provider?: string;

  @IsOptional()
  @IsString()
  description?: string;
}
