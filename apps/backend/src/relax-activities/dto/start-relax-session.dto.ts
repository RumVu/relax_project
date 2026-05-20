import { MoodType, RelaxActivityType } from '@prisma/client';
import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';

export class StartRelaxSessionDto {
  @IsEnum(RelaxActivityType)
  activityType!: RelaxActivityType;

  @IsOptional()
  @IsString()
  resourceId?: string;

  @IsOptional()
  @IsString()
  @MaxLength(80)
  title?: string;

  @IsOptional()
  @IsEnum(MoodType)
  moodBefore?: MoodType;
}
