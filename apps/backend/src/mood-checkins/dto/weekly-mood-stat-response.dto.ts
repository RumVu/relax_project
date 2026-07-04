import { ApiProperty } from '@nestjs/swagger';
import { MoodType } from '@prisma/client';

export class WeeklyMoodStatResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty() userId!: string;
  @ApiProperty({ type: 'string', format: 'date-time' }) weekStart!: Date;
  @ApiProperty({ type: 'number' }) avgScore!: number;
  @ApiProperty({ type: 'number' }) stressReducePct!: number;
  @ApiProperty({ type: 'integer' }) streakDays!: number;
  @ApiProperty({ nullable: true, enum: MoodType })
  dominantMood!: MoodType | null;
  @ApiProperty({ type: 'string', format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: 'string', format: 'date-time' }) updatedAt!: Date;
}
