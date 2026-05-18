import { Type } from 'class-transformer';
import { IsDate, IsOptional, IsString } from 'class-validator';

export class RecalculateWeeklyMoodStatsDto {
  @IsOptional()
  @Type(() => Date)
  @IsDate()
  from?: Date;

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  to?: Date;

  @IsOptional()
  @IsString()
  timezone?: string;
}
