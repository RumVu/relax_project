import { Type } from 'class-transformer';
import {
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

const MAX_EXPIRES_IN = 7 * 24 * 3600; // 7 days

export class CreateSignedUrlQueryDto {
  @IsString()
  @MaxLength(500)
  path!: string;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(MAX_EXPIRES_IN)
  expiresIn?: number;
}
