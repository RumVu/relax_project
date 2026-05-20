import { IsEmail, IsOptional, IsString } from 'class-validator';
import { StrongPassword } from '../../common/validation/strong-password.decorator';

export class RegisterDto {
  @IsEmail()
  email!: string;

  @IsString()
  @StrongPassword()
  password!: string;

  @IsOptional()
  @IsString()
  name?: string;
}
