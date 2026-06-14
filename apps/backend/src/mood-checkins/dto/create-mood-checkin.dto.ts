import {
  ArrayMaxSize,
  IsArray,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';
import { MoodType, TriggerType } from '@prisma/client';

export class CreateMoodCheckinDto {
  @IsEnum(MoodType)
  mood!: MoodType;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(10)
  intensity?: number;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  note?: string;

  @IsOptional()
  @IsArray()
  @ArrayMaxSize(10)
  @IsString({ each: true })
  tags?: string[];

  @IsOptional()
  @IsEnum(TriggerType)
  trigger?: TriggerType;
}
