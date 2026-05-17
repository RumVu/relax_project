import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import { BreakMode } from '@prisma/client';
import {
  ArrayMaxSize,
  IsArray,
  IsDateString,
  IsEnum,
  IsInt,
  IsOptional,
  IsString,
  Max,
  MaxLength,
  Min,
} from 'class-validator';

export class CreateBreakSessionDto {
  @ApiPropertyOptional({ enum: BreakMode })
  @IsOptional()
  @IsEnum(BreakMode)
  mode?: BreakMode;

  @ApiProperty({ minimum: 0, maximum: 86400 })
  @IsInt()
  @Min(0)
  @Max(86400)
  duration: number;

  @ApiProperty({ minimum: 0, maximum: 86400 })
  @IsInt()
  @Min(0)
  @Max(86400)
  plannedDuration: number;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(40)
  status?: string;

  @ApiProperty()
  @IsDateString()
  startedAt: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsDateString()
  endedAt?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsDateString()
  completedAt?: string;

  @ApiPropertyOptional()
  @IsOptional()
  @IsString()
  @MaxLength(2000)
  notes?: string;

  @ApiPropertyOptional({ type: [String] })
  @IsOptional()
  @IsArray()
  @IsString({ each: true })
  @ArrayMaxSize(20)
  activities?: string[];
}
