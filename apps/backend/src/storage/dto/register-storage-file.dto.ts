import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsDate,
  IsInt,
  IsObject,
  IsOptional,
  IsString,
  Min,
} from 'class-validator';

export class RegisterStorageFileDto {
  @IsString()
  filename!: string;

  @IsString()
  mimetype!: string;

  @IsInt()
  @Min(0)
  size!: number;

  @IsString()
  path!: string;

  @IsOptional()
  @IsString()
  publicUrl?: string;

  @IsOptional()
  @IsBoolean()
  isPublic?: boolean;

  @IsOptional()
  @Type(() => Date)
  @IsDate()
  expiresAt?: Date;

  @IsOptional()
  @IsObject()
  metadata?: Record<string, unknown>;
}
