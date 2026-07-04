import { ApiProperty } from '@nestjs/swagger';
import {
  CompanionAction,
  CompanionMood,
  CompanionPersonalizationMode,
  CompanionType,
} from '@prisma/client';
import { CompanionAssetResponseDto } from '../../companion-assets/dto/companion-asset-response.dto';

export class UserCompanionResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty() userId!: string;
  @ApiProperty({ nullable: true }) assetId!: string | null;
  @ApiProperty() name!: string;
  @ApiProperty({ enum: CompanionType }) type!: CompanionType;
  @ApiProperty({ enum: CompanionPersonalizationMode })
  personalizationMode!: CompanionPersonalizationMode;
  @ApiProperty({ enum: CompanionMood }) mood!: CompanionMood;
  @ApiProperty({ enum: CompanionAction }) action!: CompanionAction;
  @ApiProperty({ type: 'integer' }) level!: number;
  @ApiProperty({ type: 'integer' }) affection!: number;
  @ApiProperty({ type: 'integer' }) energy!: number;
  @ApiProperty({ nullable: true, type: 'string', format: 'date-time' })
  lastSeenAt!: Date | null;
  @ApiProperty({ nullable: true, type: 'string', format: 'date-time' })
  lastFedAt!: Date | null;
  @ApiProperty({ nullable: true, type: 'string', format: 'date-time' })
  lastMoodAt!: Date | null;
  @ApiProperty({ type: 'string', format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: 'string', format: 'date-time' }) updatedAt!: Date;
  @ApiProperty({
    type: () => CompanionAssetResponseDto,
    nullable: true,
    required: false,
  })
  asset?: CompanionAssetResponseDto | null;
}
