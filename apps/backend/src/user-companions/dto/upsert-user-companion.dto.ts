import {
  CompanionAction,
  CompanionMood,
  CompanionPersonalizationMode,
  CompanionType,
} from '@prisma/client';
import { IsEnum, IsInt, IsOptional, IsString, Max, Min } from 'class-validator';

export class UpsertUserCompanionDto {
  @IsOptional()
  @IsString()
  assetId?: string;

  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsEnum(CompanionType)
  type?: CompanionType;

  @IsOptional()
  @IsEnum(CompanionPersonalizationMode)
  personalizationMode?: CompanionPersonalizationMode;

  @IsOptional()
  @IsEnum(CompanionMood)
  mood?: CompanionMood;

  @IsOptional()
  @IsEnum(CompanionAction)
  action?: CompanionAction;

  @IsOptional()
  @IsInt()
  @Min(1)
  level?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100)
  affection?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100)
  energy?: number;
}
