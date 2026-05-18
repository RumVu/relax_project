import { CompanionMood, MessageTriggerType, MoodType } from '@prisma/client';
import {
  IsBoolean,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

export class UpdateCompanionMessageDto {
  @IsOptional()
  @IsString()
  content?: string;

  @IsOptional()
  @IsEnum(MessageTriggerType)
  triggerType?: MessageTriggerType;

  @IsOptional()
  @IsEnum(MoodType)
  mood?: MoodType;

  @IsOptional()
  @IsEnum(CompanionMood)
  companionMood?: CompanionMood;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(23)
  minHour?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(23)
  maxHour?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  weight?: number;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
