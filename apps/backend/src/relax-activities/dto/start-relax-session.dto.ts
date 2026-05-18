import { MoodType, RelaxActivityType } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  IsDate,
  IsEnum,
  IsOptional,
  IsString,
  MaxLength,
} from 'class-validator';

export class StartRelaxSessionDto {
  @IsEnum(RelaxActivityType)
  activityType!: RelaxActivityType;

  @IsOptional()
  @IsString()
  resourceId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  title?: string;

  @IsOptional()
  @IsEnum(MoodType)
  moodBefore?: MoodType;

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  startedAt?: Date;
}
