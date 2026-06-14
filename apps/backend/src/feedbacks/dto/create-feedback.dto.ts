import { IsNotEmpty, IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateFeedbackDto {
  @IsOptional()
  @IsString()
  @MaxLength(120)
  subject?: string;

  @IsNotEmpty()
  @IsString()
  @MaxLength(1000)
  message!: string;
}
