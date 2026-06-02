import { IsNotEmpty, IsString } from 'class-validator';
import { StrongPassword } from '../../common/validation/strong-password.decorator';

export class ChangePasswordDto {
  @IsString()
  @IsNotEmpty()
  currentPassword!: string;

  @IsString()
  @StrongPassword()
  newPassword!: string;
}
