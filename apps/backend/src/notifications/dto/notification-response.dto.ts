import { ApiProperty } from '@nestjs/swagger';
import { NotificationType, PushPlatform, PushProvider } from '@prisma/client';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class NotificationResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty() userId!: string;
  @ApiProperty() title!: string;
  @ApiProperty() message!: string;
  @ApiProperty({ enum: NotificationType }) type!: NotificationType;
  @ApiProperty({ nullable: true }) relatedEntity!: string | null;
  @ApiProperty({ nullable: true }) relatedId!: string | null;
  @ApiProperty() isRead!: boolean;
  @ApiProperty({ nullable: true, type: 'string', format: 'date-time' })
  readAt!: Date | null;
  @ApiProperty({ type: 'string', format: 'date-time' }) createdAt!: Date;
}

export class NotificationPageDto extends PaginatedDto {
  @ApiProperty({ type: () => [NotificationResponseDto] })
  items!: NotificationResponseDto[];
}

export class UnreadCountResponseDto {
  @ApiProperty({ type: 'integer' }) count!: number;
}

export class PushDeviceResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty() userId!: string;
  @ApiProperty() token!: string;
  @ApiProperty({ enum: PushPlatform }) platform!: PushPlatform;
  @ApiProperty({ enum: PushProvider }) provider!: PushProvider;
  @ApiProperty({ nullable: true }) deviceId!: string | null;
  @ApiProperty({ nullable: true }) deviceName!: string | null;
  @ApiProperty({ nullable: true }) appVersion!: string | null;
  @ApiProperty({ nullable: true }) timezone!: string | null;
  @ApiProperty() enabled!: boolean;
  @ApiProperty({ type: 'string', format: 'date-time' }) lastSeenAt!: Date;
  @ApiProperty({ type: 'string', format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: 'string', format: 'date-time' }) updatedAt!: Date;
}
