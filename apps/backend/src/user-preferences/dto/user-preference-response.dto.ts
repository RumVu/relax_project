import { ApiProperty } from '@nestjs/swagger';
import { ThemeMode } from '@prisma/client';

export class UserPreferenceResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty() userId!: string;
  @ApiProperty() language!: string;
  @ApiProperty() timezone!: string;
  @ApiProperty({ nullable: true, type: 'number' }) latitude!: number | null;
  @ApiProperty({ nullable: true, type: 'number' }) longitude!: number | null;
  @ApiProperty({ nullable: true }) locationName!: string | null;
  @ApiProperty() weatherEnabled!: boolean;
  @ApiProperty({ enum: ThemeMode }) themeMode!: ThemeMode;
  @ApiProperty({ nullable: true }) themeId!: string | null;
  @ApiProperty() enableCompanionBubble!: boolean;
  @ApiProperty({ type: 'integer' }) bubbleIntervalSeconds!: number;
  @ApiProperty() enableSound!: boolean;
  @ApiProperty() enableHaptics!: boolean;
  @ApiProperty() pushNotificationsEnabled!: boolean;
  @ApiProperty() emailNotificationsEnabled!: boolean;
  @ApiProperty({ type: 'string', format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: 'string', format: 'date-time' }) updatedAt!: Date;
}
