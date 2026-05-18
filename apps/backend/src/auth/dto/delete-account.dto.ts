import { IsEnum, IsOptional, IsString, MinLength } from 'class-validator';

export enum DeleteAccountMode {
  SOFT = 'SOFT',
  HARD = 'HARD',
}

export class DeleteAccountDto {
  @IsOptional()
  @IsEnum(DeleteAccountMode)
  mode?: DeleteAccountMode;

  @IsOptional()
  @IsString()
  @MinLength(6)
  password?: string;
}
