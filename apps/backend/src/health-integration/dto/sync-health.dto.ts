import { IsDateString, IsInt, IsOptional, Min } from 'class-validator';

export class SyncHealthDto {
  @IsOptional()
  @IsInt()
  @Min(0)
  sleepMinutes?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  heartRate?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  steps?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  breathingMinutes?: number;

  @IsDateString()
  date!: string;
}
