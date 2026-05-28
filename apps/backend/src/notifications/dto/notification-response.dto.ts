import { NotificationType, PushPlatform, PushProvider } from '@prisma/client';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class NotificationResponseDto {
  id!: string;
  userId!: string;
  title!: string;
  message!: string;
  type!: NotificationType;
  relatedEntity!: string | null;
  relatedId!: string | null;
  isRead!: boolean;
  readAt!: Date | null;
  createdAt!: Date;
}

export class NotificationPageDto extends PaginatedDto {
  items!: NotificationResponseDto[];
}

export class UnreadCountResponseDto {
  count!: number;
}

export class PushDeviceResponseDto {
  id!: string;
  userId!: string;
  token!: string;
  platform!: PushPlatform;
  provider!: PushProvider;
  deviceId!: string | null;
  deviceName!: string | null;
  appVersion!: string | null;
  timezone!: string | null;
  enabled!: boolean;
  lastSeenAt!: Date;
  createdAt!: Date;
  updatedAt!: Date;
}
