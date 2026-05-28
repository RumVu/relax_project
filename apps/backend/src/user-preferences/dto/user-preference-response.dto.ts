import { ThemeMode } from '@prisma/client';

export class UserPreferenceResponseDto {
  id!: string;
  userId!: string;
  language!: string;
  timezone!: string;
  latitude!: number | null;
  longitude!: number | null;
  locationName!: string | null;
  weatherEnabled!: boolean;
  themeMode!: ThemeMode;
  themeId!: string | null;
  enableCompanionBubble!: boolean;
  bubbleIntervalSeconds!: number;
  enableSound!: boolean;
  enableHaptics!: boolean;
  pushNotificationsEnabled!: boolean;
  emailNotificationsEnabled!: boolean;
  createdAt!: Date;
  updatedAt!: Date;
}
