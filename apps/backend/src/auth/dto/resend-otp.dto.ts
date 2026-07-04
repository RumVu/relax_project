import { IsEmail, IsIn } from 'class-validator';

export class ResendOtpDto {
  @IsEmail()
  email!: string;

  @IsIn(['registration', 'password-reset'])
  purpose!: 'registration' | 'password-reset';
}
