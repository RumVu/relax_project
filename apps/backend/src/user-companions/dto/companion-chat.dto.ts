import { IsNotEmpty, IsString, MaxLength } from 'class-validator';

export class CompanionChatDto {
  @IsString()
  @IsNotEmpty()
  @MaxLength(1000)
  message!: string;
}
