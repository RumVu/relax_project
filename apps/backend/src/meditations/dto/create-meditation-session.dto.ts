import { IsDateString, IsEnum, IsInt, IsOptional, IsString, Max, Min } from 'class-validator';
import { MoodType } from '@prisma/client';

export class CreateMeditationSessionDto {
  @IsOptional()
  @IsString()
  guideId?: string;

  @IsInt()
  @Min(1)
  duration!: number;

  @IsDateString()
  startedAt!: string;

  @IsOptional()
  @IsDateString()
  endedAt?: string;

  @IsOptional()
  @IsString()
  focusArea?: string;

  @IsOptional()
  @IsEnum(MoodType)
  mood?: MoodType;

  @IsOptional()
  @IsInt()
  @Min(1)
  @Max(10)
  quality?: number;

  @IsOptional()
  @IsString()
  notes?: string;
}
