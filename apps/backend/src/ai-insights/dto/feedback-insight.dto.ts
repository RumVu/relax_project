import { ApiProperty } from '@nestjs/swagger';
import { IsBoolean } from 'class-validator';

export class FeedbackInsightDto {
  @ApiProperty({
    description: 'True if the insight was helpful, false otherwise.',
  })
  @IsBoolean()
  useful!: boolean;
}
