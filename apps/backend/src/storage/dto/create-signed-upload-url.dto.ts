import {
  IsBoolean,
  IsOptional,
  IsString,
  Matches,
  MaxLength,
} from 'class-validator';

const SAFE_PATH_REGEX = /^[a-zA-Z0-9_\-/.]+$/;
const ALLOWED_EXTENSIONS_REGEX =
  /\.(jpg|jpeg|png|gif|webp|svg|mp3|mp4|wav|ogg|pdf|json|webm)$/i;

export class CreateSignedUploadUrlDto {
  @IsString()
  @MaxLength(500)
  @Matches(SAFE_PATH_REGEX, { message: 'path contains invalid characters' })
  @Matches(ALLOWED_EXTENSIONS_REGEX, { message: 'file extension not allowed' })
  path!: string;

  @IsOptional()
  @IsBoolean()
  upsert?: boolean;
}
