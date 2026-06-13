import { IsString, MaxLength } from 'class-validator';

export class CheckContentDto {
  @IsString()
  @MaxLength(5000)
  text!: string;
}
