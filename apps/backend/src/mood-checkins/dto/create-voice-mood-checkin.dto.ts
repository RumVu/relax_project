import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class CreateVoiceMoodCheckinDto {
  @IsNotEmpty()
  @IsString()
  @MaxLength(1000)
  text!: string;
}
