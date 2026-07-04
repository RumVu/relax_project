import { ApiProperty } from '@nestjs/swagger';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class BreathingExerciseResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty() title!: string;
  @ApiProperty({ nullable: true }) description!: string | null;
  @ApiProperty({ type: 'integer' }) inhaleSeconds!: number;
  @ApiProperty({ type: 'integer' }) holdSeconds!: number;
  @ApiProperty({ type: 'integer' }) exhaleSeconds!: number;
  @ApiProperty({ type: 'integer' }) cycles!: number;
  @ApiProperty({ nullable: true, type: 'integer' }) duration!: number | null;
  @ApiProperty({ nullable: true }) imageUrl!: string | null;
  @ApiProperty() isActive!: boolean;
  @ApiProperty({ type: 'string', format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: 'string', format: 'date-time' }) updatedAt!: Date;
}

export class BreathingExercisePageDto extends PaginatedDto {
  @ApiProperty({ type: () => [BreathingExerciseResponseDto] })
  items!: BreathingExerciseResponseDto[];
}
