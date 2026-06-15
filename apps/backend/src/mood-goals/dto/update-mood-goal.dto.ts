import {
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  IsDateString,
} from 'class-validator';
import { MoodGoalStatus, MoodType } from '@prisma/client';

export class UpdateMoodGoalDto {
  @IsOptional()
  @IsString()
  @MaxLength(100)
  title?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;

  @IsOptional()
  @IsEnum(MoodGoalStatus)
  status?: MoodGoalStatus;

  @IsOptional()
  @IsEnum(MoodType)
  targetMood?: MoodType;

  @IsOptional()
  @IsInt()
  @Min(1)
  targetCount?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  targetDays?: number;

  @IsOptional()
  @IsDateString()
  endDate?: string;
}
