import { ReminderType } from '@prisma/client';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class ReminderResponseDto {
  id!: string;
  userId!: string;
  title!: string;
  message!: string | null;
  type!: ReminderType;
  scheduledAt!: Date;
  repeatRule!: string | null;
  isActive!: boolean;
  createdAt!: Date;
  updatedAt!: Date;
}

export class ReminderPageDto extends PaginatedDto {
  items!: ReminderResponseDto[];
}
