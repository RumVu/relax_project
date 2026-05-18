import { IsBoolean, IsInt, IsOptional, IsString, Min } from 'class-validator';

export class UpdateBreathingExerciseDto {
  @IsOptional()
  @IsString()
  title?: string;

  @IsOptional()
  @IsString()
  description?: string;

  @IsOptional()
  @IsInt()
  @Min(0)
  inhaleSeconds?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  holdSeconds?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  exhaleSeconds?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  cycles?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  duration?: number;

  @IsOptional()
  @IsString()
  imageUrl?: string;

  @IsOptional()
  @IsBoolean()
  isActive?: boolean;
}
