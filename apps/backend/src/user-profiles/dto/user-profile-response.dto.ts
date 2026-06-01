export class UserProfileResponseDto {
  id!: string;
  userId!: string;
  displayName!: string | null;
  bio!: string | null;
  avatar?: string | null;
  birthday!: Date | null;
  zodiacSign!: string | null;
  chineseZodiac!: string | null;
  totalMoodCheckins!: number;
  totalJournalPosts!: number;
  currentStreak!: number;
  longestStreak!: number;
  createdAt!: Date;
  updatedAt!: Date;
}
