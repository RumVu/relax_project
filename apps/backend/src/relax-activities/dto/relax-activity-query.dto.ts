import { Type } from 'class-transformer';
import {
  IsDate,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';
import { RelaxActivityType } from '@prisma/client';

export enum RelaxStatsPeriod {
  WEEK = 'week',
  MONTH = 'month',
  QUARTER = 'quarter',
  YEAR = 'year',
  CUSTOM = 'custom',
}

export class RelaxActivityQueryDto {
  @IsOptional()
  @IsEnum(RelaxActivityType)
  activityType?: RelaxActivityType;

  @IsOptional()
  @IsEnum(RelaxStatsPeriod)
  period?: RelaxStatsPeriod;

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  from?: Date;

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  to?: Date;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(-720)
  @Max(840)
  timezoneOffsetMinutes?: number;

  @IsOptional()
  @IsString()
  timezone?: string;
}
