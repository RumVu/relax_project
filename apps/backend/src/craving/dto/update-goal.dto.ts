import { IsInt, IsOptional, Min } from 'class-validator';

export class UpdateGoalDto {
  @IsOptional()
  @IsInt()
  @Min(0)
  dailyTarget?: number;

  @IsOptional()
  @IsInt()
  @Min(0)
  currentDaily?: number;

  @IsOptional()
  @IsInt()
  @Min(1)
  replacementGoal?: number;
}
