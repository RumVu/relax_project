export class StorageFileResponseDto {
  id!: string;
  userId!: string | null;
  filename!: string;
  mimetype!: string;
  size!: number;
  provider!: string;
  path!: string | null;
  url!: string;
  publicUrl!: string | null;
  bucket!: string | null;
  isPublic!: boolean;
  expiresAt!: Date | null;
  createdAt!: Date;
}
