import { CompanionMood, MessageTriggerType, MoodType } from '@prisma/client';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class CompanionMessageResponseDto {
  id!: string;
  content!: string;
  triggerType!: MessageTriggerType;
  mood!: MoodType | null;
  companionMood!: CompanionMood | null;
  minHour!: number | null;
  maxHour!: number | null;
  weight!: number;
  isActive!: boolean;
  createdAt!: Date;
  updatedAt!: Date;
}

export class CompanionMessagePageDto extends PaginatedDto {
  items!: CompanionMessageResponseDto[];
}
