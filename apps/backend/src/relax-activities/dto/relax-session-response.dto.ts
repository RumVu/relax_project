import { ApiProperty } from '@nestjs/swagger';
import {
  MoodType,
  RelaxActivityType,
  RelaxSessionStatus,
} from '@prisma/client';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class RelaxSessionResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty() userId!: string;
  @ApiProperty({ enum: RelaxActivityType }) activityType!: RelaxActivityType;
  @ApiProperty({ enum: RelaxSessionStatus }) status!: RelaxSessionStatus;
  @ApiProperty({ nullable: true }) resourceId!: string | null;
  @ApiProperty() title!: string;
  @ApiProperty({ type: 'string', format: 'date-time' }) startedAt!: Date;
  @ApiProperty({ nullable: true, type: 'string', format: 'date-time' })
  endedAt!: Date | null;
  @ApiProperty({ nullable: true, type: 'integer' }) duration!: number | null;
  @ApiProperty({ nullable: true, enum: MoodType }) moodBefore!: MoodType | null;
  @ApiProperty({ nullable: true, enum: MoodType }) moodAfter!: MoodType | null;
  @ApiProperty({ nullable: true, type: 'integer' }) reliefLevel!: number | null;
  @ApiProperty({ nullable: true, type: 'number' }) stressReliefPercent!:
    | number
    | null;
  @ApiProperty({ nullable: true }) note!: string | null;
  @ApiProperty({ nullable: true }) nextActionAccepted!: string | null;
  @ApiProperty({ type: 'string', format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: 'string', format: 'date-time' }) updatedAt!: Date;
}

export class RelaxSessionPageDto extends PaginatedDto {
  @ApiProperty({ type: () => [RelaxSessionResponseDto] })
  items!: RelaxSessionResponseDto[];
}
