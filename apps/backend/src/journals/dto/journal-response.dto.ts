import { MoodType } from '@prisma/client';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class JournalResponseDto {
  id!: string;
  userId!: string;
  title!: string | null;
  content!: string;
  mood!: MoodType | null;
  tags!: string[];
  isPrivate!: boolean;
  isFavorite!: boolean;
  createdAt!: Date;
  updatedAt!: Date;
}

export class JournalPageDto extends PaginatedDto {
  items!: JournalResponseDto[];
}
