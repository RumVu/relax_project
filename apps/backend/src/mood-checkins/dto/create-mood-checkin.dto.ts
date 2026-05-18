import { Type } from 'class-transformer';
import {
  ArrayMaxSize,
  IsArray,
  IsDate,
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
  @IsInt()
  @Min(0)
  @Max(100)
  rawScore?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  @Max(100)
  finalScore?: number;

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  scoredAt?: Date;

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
  @Type(() => Date)
  @IsDate()
  checkedAt?: Date;
}
