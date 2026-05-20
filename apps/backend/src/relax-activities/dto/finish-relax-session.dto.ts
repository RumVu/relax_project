import { MoodType } from '@prisma/client';
import {
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

export class FinishRelaxSessionDto {
  @IsOptional()
  @IsEnum(MoodType)
  moodAfter?: MoodType;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(5)
  reliefLevel?: number;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  note?: string;

  @IsOptional()
  @IsString()
  @MaxLength(120)
  nextActionAccepted?: string;
}
