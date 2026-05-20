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
import { MoodType } from '@prisma/client';

export class CreateMoodCheckinDto {
  @IsEnum(MoodType)
  mood!: MoodType;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(5)
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
}
