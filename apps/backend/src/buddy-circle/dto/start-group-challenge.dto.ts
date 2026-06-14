import { IsInt, IsString, MaxLength, Min } from 'class-validator';

export class StartGroupChallengeDto {
  @IsString()
  @MaxLength(120)
  title!: string;

  @IsString()
  @MaxLength(500)
  description!: string;

  @IsInt()
  @Min(1)
  durationDays!: number;

  @IsInt()
  @Min(1)
  goal!: number;
}
