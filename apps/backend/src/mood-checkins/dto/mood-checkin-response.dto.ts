import { ApiProperty } from '@nestjs/swagger';
import { MoodType } from '@prisma/client';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class MoodCheckinResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty() userId!: string;
  @ApiProperty({ enum: MoodType }) mood!: MoodType;
  @ApiProperty({ nullable: true, type: 'integer' }) intensity!: number | null;
  @ApiProperty({ nullable: true, type: 'integer' }) rawScore!: number | null;
  @ApiProperty({ nullable: true, type: 'integer' }) finalScore!: number | null;
  @ApiProperty({ nullable: true, type: 'string', format: 'date-time' })
  scoredAt!: Date | null;
  @ApiProperty({ nullable: true }) note!: string | null;
  @ApiProperty({ type: [String] }) tags!: string[];
  @ApiProperty({ type: 'string', format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: 'string', format: 'date-time' }) updatedAt!: Date;
}

export class MoodCheckinPageDto extends PaginatedDto {
  @ApiProperty({ type: () => [MoodCheckinResponseDto] })
  items!: MoodCheckinResponseDto[];
}
