import { ThemeMode } from '@prisma/client';
import {
  IsBoolean,
  IsEnum,
  IsNotEmpty,
  IsOptional,
  IsString,
} from 'class-validator';

export class CreateAppThemeDto {
  @IsString()
  @IsNotEmpty()
  name!: string;

  @IsEnum(ThemeMode)
  mode!: ThemeMode;

  @IsString()
  @IsNotEmpty()
  backgroundColor!: string;

  @IsString()
  @IsNotEmpty()
  surfaceColor!: string;

  @IsString()
  @IsNotEmpty()
  primaryColor!: string;

  @IsOptional()
  @IsString()
  secondaryColor?: string;

  @IsOptional()
  @IsString()
  accentColor?: string;

  @IsString()
  @IsNotEmpty()
  textColor!: string;

  @IsOptional()
  @IsString()
  mutedTextColor?: string;

  @IsOptional()
  @IsBoolean()
  isDefault?: boolean;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
