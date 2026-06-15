import {
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  MaxLength,
  Min,
  IsDateString,
  IsArray,
  ValidateNested,
} from 'class-validator';
import { Type } from 'class-transformer';
import { MoodGoalType, MoodType } from '@prisma/client';

export class CreateMilestoneDto {
  @IsString()
  @MaxLength(100)
  title!: string;

  @IsInt()
  @Min(1)
  target!: number;
}

export class CreateMoodGoalDto {
  @IsString()
  @MaxLength(100)
  title!: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  description?: string;

  @IsEnum(MoodGoalType)
  type!: MoodGoalType;

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

  @IsOptional()
  @IsArray()
  @ValidateNested({ each: true })
  @Type(() => CreateMilestoneDto)
  milestones?: CreateMilestoneDto[];
}
