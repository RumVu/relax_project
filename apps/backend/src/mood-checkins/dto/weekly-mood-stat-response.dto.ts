import { MoodType } from '@prisma/client';

export class WeeklyMoodStatResponseDto {
  id!: string;
  userId!: string;
  weekStart!: Date;
  avgScore!: number;
  stressReducePct!: number;
  streakDays!: number;
  dominantMood!: MoodType | null;
  createdAt!: Date;
  updatedAt!: Date;
}
