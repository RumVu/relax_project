import { IsString } from 'class-validator';
import { StrongPassword } from '../../common/validation/strong-password.decorator';

export class ResetPasswordDto {
  @IsString()
  token!: string;

  @IsString()
  @StrongPassword()
  password!: string;
}
