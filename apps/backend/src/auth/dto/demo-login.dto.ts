import { ApiPropertyOptional } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class DemoLoginDto {
  @ApiPropertyOptional({ description: 'Optional device name for the session' })
  @IsString()
  @IsOptional()
  deviceName?: string;
}
