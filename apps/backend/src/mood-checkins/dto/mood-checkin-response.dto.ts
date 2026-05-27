import { MoodType } from '@prisma/client';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class MoodCheckinResponseDto {
  id!: string;
  userId!: string;
  mood!: MoodType;
  intensity!: number | null;
  rawScore!: number | null;
  finalScore!: number | null;
  scoredAt!: Date | null;
  note!: string | null;
  tags!: string[];
  createdAt!: Date;
  updatedAt!: Date;
}

export class MoodCheckinPageDto extends PaginatedDto {
  items!: MoodCheckinResponseDto[];
}
