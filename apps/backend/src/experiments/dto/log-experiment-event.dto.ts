import { ApiProperty } from '@nestjs/swagger';
import { IsIn, IsString } from 'class-validator';

export class LogExperimentEventDto {
  @ApiProperty({ example: 'onboarding_flow_v2' })
  @IsString()
  experimentKey!: string;

  @ApiProperty({ example: 'A' })
  @IsString()
  variant!: string;

  @ApiProperty({ example: 'viewed', enum: ['viewed', 'converted'] })
  @IsString()
  @IsIn(['viewed', 'converted'])
  eventType!: string;
}
