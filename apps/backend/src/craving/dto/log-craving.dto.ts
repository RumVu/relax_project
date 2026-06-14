import {
  IsBoolean,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { CravingReason } from '@prisma/client';

export class LogCravingDto {
  @IsEnum(CravingReason)
  reason!: CravingReason;

  @IsInt()
  @Min(1)
  @Max(10)
  intensityBefore!: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(10)
  intensityAfter?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  duration?: number;

  @IsOptional()
  @IsString()
  @MaxLength(200)
  activityUsed?: string;

  @IsOptional()
  @IsBoolean()
  resisted?: boolean;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  note?: string;
}
