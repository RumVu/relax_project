import { ApiProperty, ApiPropertyOptional, PartialType } from '@nestjs/swagger';
import { BillingCycle } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsDateString,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Length,
  Matches,
  Min,
} from 'class-validator';

export class CreateTierDto {
  @ApiProperty({
    description:
      'Unique internal code, UPPER_SNAKE only. E.g. CHILL_PLUS, CHILL_PLUS_ANNUAL.',
    example: 'CHILL_PLUS_QUARTERLY',
  })
  @IsString()
  @Matches(/^[A-Z][A-Z0-9_]+$/, {
    message: 'name must be UPPER_SNAKE_CASE (A-Z, 0-9, _)',
  })
  @Length(2, 48)
  name!: string;

  @ApiPropertyOptional({
    description: 'Display title shown to users. Falls back to name when null.',
  })
  @IsOptional()
  @IsString()
  @Length(1, 80)
  title?: string;

  @ApiPropertyOptional({ description: 'Marketing copy / description.' })
  @IsOptional()
  @IsString()
  @Length(0, 500)
  description?: string;

  @ApiProperty({
    description: 'List price in the smallest visible unit (e.g. VND).',
    example: 49000,
  })
  @Type(() => Number)
  @Min(0)
  price!: number;

  @ApiPropertyOptional({
    description: 'Active sale price. Effective when within sale window.',
  })
  @IsOptional()
  @Type(() => Number)
  @Min(0)
  salePrice?: number;

  @ApiPropertyOptional({
    description:
      'Short label shown beside the sale price, e.g. "BLACK FRIDAY -20%".',
  })
  @IsOptional()
  @IsString()
  @Length(0, 60)
  saleLabel?: string;

  @ApiPropertyOptional({ description: 'ISO datetime when the sale starts.' })
  @IsOptional()
  @IsDateString()
  saleStartsAt?: string;

  @ApiPropertyOptional({ description: 'ISO datetime when the sale ends.' })
  @IsOptional()
  @IsDateString()
  saleEndsAt?: string;

  @ApiPropertyOptional({ description: 'ISO 4217 currency. Defaults to VND.' })
  @IsOptional()
  @IsString()
  @Length(3, 3)
  currency?: string;

  @ApiProperty({ enum: BillingCycle })
  @IsEnum(BillingCycle)
  billingCycle!: BillingCycle;

  @ApiPropertyOptional({
    description: 'Display order, low to high.',
    default: 0,
  })
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  displayOrder?: number;

  @ApiPropertyOptional({ default: true })
  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}

export class UpdateTierDto extends PartialType(CreateTierDto) {}
