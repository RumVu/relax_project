import { ApiProperty, ApiPropertyOptional } from '@nestjs/swagger';
import {
  ArrayMinSize,
  IsArray,
  IsBoolean,
  IsOptional,
  IsString,
} from 'class-validator';

export class CreateExperimentDto {
  @ApiProperty({ example: 'onboarding_flow_v2' })
  @IsString()
  key!: string;

  @ApiProperty({ example: 'Onboarding Flow V2' })
  @IsString()
  name!: string;

  @ApiPropertyOptional({ example: 'Test new onboarding experience' })
  @IsString()
  @IsOptional()
  description?: string;

  @ApiProperty({ example: ['A', 'B'], type: [String] })
  @IsArray()
  @IsString({ each: true })
  @ArrayMinSize(2)
  variants!: string[];

  @ApiPropertyOptional({ default: true })
  @IsBoolean()
  @IsOptional()
  isActive?: boolean = true;
}
