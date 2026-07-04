import { ApiProperty } from '@nestjs/swagger';
import { CompanionMood, MessageTriggerType, MoodType } from '@prisma/client';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class CompanionMessageResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty() content!: string;
  @ApiProperty({ enum: MessageTriggerType }) triggerType!: MessageTriggerType;
  @ApiProperty({ nullable: true, enum: MoodType }) mood!: MoodType | null;
  @ApiProperty({ nullable: true, enum: CompanionMood })
  companionMood!: CompanionMood | null;
  @ApiProperty({ nullable: true, type: 'integer' }) minHour!: number | null;
  @ApiProperty({ nullable: true, type: 'integer' }) maxHour!: number | null;
  @ApiProperty({ type: 'integer' }) weight!: number;
  @ApiProperty() isActive!: boolean;
  @ApiProperty({ type: 'string', format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: 'string', format: 'date-time' }) updatedAt!: Date;
}

export class CompanionMessagePageDto extends PaginatedDto {
  @ApiProperty({ type: () => [CompanionMessageResponseDto] })
  items!: CompanionMessageResponseDto[];
}
