export class SessionResponseDto {
  id!: string;
  userId!: string;
  userAgent!: string | null;
  ipAddress!: string | null;
  expiresAt!: Date;
  createdAt!: Date;
}
