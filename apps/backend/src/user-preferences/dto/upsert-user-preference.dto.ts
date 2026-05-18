import { ThemeMode } from '@prisma/client';
import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsEnum,
  IsInt,
  IsLatitude,
  IsLongitude,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class UpsertUserPreferenceDto {
  @IsOptional()
  @IsString()
  language?: string;

  @IsOptional()
  @IsString()
  timezone?: string;

  @IsOptional()
  @Type(() => Number)
  @IsLatitude()
  latitude?: number;

  @IsOptional()
  @Type(() => Number)
  @IsLongitude()
  longitude?: number;

  @IsOptional()
  @IsString()
  locationName?: string;

  @IsOptional()
  @IsBoolean()
  weatherEnabled?: boolean;

  @IsOptional()
  @IsEnum(ThemeMode)
  themeMode?: ThemeMode;

  @IsOptional()
  @IsString()
  themeId?: string;

  @IsOptional()
  @IsBoolean()
  enableCompanionBubble?: boolean;

  @IsOptional()
  @IsInt()
  @Min(1)
  bubbleIntervalSeconds?: number;

  @IsOptional()
  @IsBoolean()
  enableSound?: boolean;

  @IsOptional()
  @IsBoolean()
  enableHaptics?: boolean;

  @IsOptional()
  @IsBoolean()
  pushNotificationsEnabled?: boolean;

  @IsOptional()
  @IsBoolean()
  emailNotificationsEnabled?: boolean;
}
