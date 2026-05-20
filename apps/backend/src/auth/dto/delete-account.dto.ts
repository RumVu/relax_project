import { IsEnum, IsNotEmpty, IsOptional, IsString } from 'class-validator';

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
  @IsNotEmpty()
  password?: string;
}
