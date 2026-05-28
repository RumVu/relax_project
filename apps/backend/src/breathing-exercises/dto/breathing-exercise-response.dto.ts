import { PaginatedDto } from '../../common/dto/paginated.dto';

export class BreathingExerciseResponseDto {
  id!: string;
  title!: string;
  description!: string | null;
  inhaleSeconds!: number;
  holdSeconds!: number;
  exhaleSeconds!: number;
  cycles!: number;
  duration!: number | null;
  imageUrl!: string | null;
  isActive!: boolean;
  createdAt!: Date;
  updatedAt!: Date;
}

export class BreathingExercisePageDto extends PaginatedDto {
  items!: BreathingExerciseResponseDto[];
}
