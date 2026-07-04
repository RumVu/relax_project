import { ApiProperty } from '@nestjs/swagger';

export class UserProfileResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty() userId!: string;
  @ApiProperty({ nullable: true }) displayName!: string | null;
  @ApiProperty({ nullable: true }) bio!: string | null;
  @ApiProperty({ nullable: true, required: false }) avatar?: string | null;
  @ApiProperty({ nullable: true, type: 'string', format: 'date-time' })
  birthday!: Date | null;
  @ApiProperty({ nullable: true }) zodiacSign!: string | null;
  @ApiProperty({ nullable: true }) chineseZodiac!: string | null;
  @ApiProperty({ type: 'integer' }) totalMoodCheckins!: number;
  @ApiProperty({ type: 'integer' }) totalJournalPosts!: number;
  @ApiProperty({ type: 'integer' }) currentStreak!: number;
  @ApiProperty({ type: 'integer' }) longestStreak!: number;
  @ApiProperty({ type: 'string', format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: 'string', format: 'date-time' }) updatedAt!: Date;
}
