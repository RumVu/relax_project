import { IsEmail, IsString, Length } from 'class-validator';
import { StrongPassword } from '../../common/validation/strong-password.decorator';

export class ForgotPasswordOtpDto {
  @IsEmail()
  email!: string;

  @IsString()
  @Length(6, 6)
  code!: string;

  @IsString()
  @StrongPassword()
  password!: string;
}
