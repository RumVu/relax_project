import { CompanionPersonalizationMode } from '@prisma/client';
import { IsBoolean, IsEnum, IsOptional, IsString } from 'class-validator';

export class SwitchCompanionPersonalizationDto {
  @IsEnum(CompanionPersonalizationMode)
  personalizationMode!: CompanionPersonalizationMode;

  @IsOptional()
  @IsString()
  assetId?: string;

  @IsOptional()
  @IsBoolean()
  preserveProgress?: boolean;

  @IsOptional()
  @IsBoolean()
  resetVisualState?: boolean;
}
