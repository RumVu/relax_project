import { NotificationType } from '@prisma/client';
import { IsEnum, IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateNotificationDto {
  @IsString()
  @MaxLength(120)
  title!: string;

  @IsString()
  @MaxLength(500)
  message!: string;

  @IsOptional()
  @IsEnum(NotificationType)
  type?: NotificationType;
}
