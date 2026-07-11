import { Type } from 'class-transformer';
import {
  IsDate,
  IsOptional,
  IsString,
  IsUrl,
  MaxLength,
} from 'class-validator';

export class UpsertUserProfileDto {
  @IsOptional()
  @IsString()
  @MaxLength(100)
  displayName?: string;

  @IsOptional()
  @IsString()
  @MaxLength(500)
  bio?: string;

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  birthday?: Date;

  /**
   * Public URL of the user's avatar (typically Supabase public-asset
   * URL after uploading via /storage/signed-upload-url). Lives on the
   * User record, not UserProfile — service syncs both for convenience.
   */
  @IsOptional()
  @IsUrl({ require_protocol: true })
  avatar?: string;
}
