import { IsBoolean, IsOptional, IsString } from 'class-validator';

export class CreateSignedUploadUrlDto {
  @IsString()
  path!: string;

  @IsOptional()
  @IsBoolean()
  upsert?: boolean;
}
