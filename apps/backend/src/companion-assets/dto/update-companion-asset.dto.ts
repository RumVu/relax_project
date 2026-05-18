import { CompanionType } from '@prisma/client';
import { IsBoolean, IsEnum, IsOptional, IsString } from 'class-validator';

export class UpdateCompanionAssetDto {
  @IsOptional()
  @IsString()
  name?: string;

  @IsOptional()
  @IsEnum(CompanionType)
  type?: CompanionType;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsString()
  previewImageUrl?: string;

  @IsOptional()
  @IsString()
  spriteSheetUrl?: string;

  @IsOptional()
  @IsString()
  idleAnimationUrl?: string;

  @IsOptional()
  @IsString()
  sleepAnimationUrl?: string;

  @IsOptional()
  @IsString()
  walkAnimationUrl?: string;

  @IsOptional()
  @IsString()
  primaryColor?: string;

  @IsOptional()
  @IsString()
  secondaryColor?: string;

  @IsOptional()
  @IsString()
  accentColor?: string;

  @IsOptional()
  @IsBoolean()
  isDefault?: boolean;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
