import { MoodType } from '@prisma/client';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class CozyQuoteResponseDto {
  id!: string;
  content!: string;
  author!: string | null;
  mood!: MoodType | null;
  imageUrl!: string | null;
  lang!: string;
  isActive!: boolean;
  createdAt!: Date;
  updatedAt!: Date;
}

export class CozyQuotePageDto extends PaginatedDto {
  items!: CozyQuoteResponseDto[];
}
