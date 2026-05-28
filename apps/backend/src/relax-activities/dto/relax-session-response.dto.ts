import {
  MoodType,
  RelaxActivityType,
  RelaxSessionStatus,
} from '@prisma/client';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class RelaxSessionResponseDto {
  id!: string;
  userId!: string;
  activityType!: RelaxActivityType;
  status!: RelaxSessionStatus;
  resourceId!: string | null;
  title!: string;
  startedAt!: Date;
  endedAt!: Date | null;
  duration!: number | null;
  moodBefore!: MoodType | null;
  moodAfter!: MoodType | null;
  reliefLevel!: number | null;
  stressReliefPercent!: number | null;
  note!: string | null;
  nextActionAccepted!: string | null;
  createdAt!: Date;
  updatedAt!: Date;
}

export class RelaxSessionPageDto extends PaginatedDto {
  items!: RelaxSessionResponseDto[];
}
