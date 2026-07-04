import { ApiProperty } from '@nestjs/swagger';
import { CompanionType } from '@prisma/client';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class CompanionAssetResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty() name!: string;
  @ApiProperty({ enum: CompanionType }) type!: CompanionType;
  @ApiProperty({ nullable: true }) description!: string | null;
  @ApiProperty({ nullable: true }) previewImageUrl!: string | null;
  @ApiProperty({ nullable: true }) spriteSheetUrl!: string | null;
  @ApiProperty({ nullable: true }) idleAnimationUrl!: string | null;
  @ApiProperty({ nullable: true }) sleepAnimationUrl!: string | null;
  @ApiProperty({ nullable: true }) walkAnimationUrl!: string | null;
  @ApiProperty({ nullable: true }) primaryColor!: string | null;
  @ApiProperty({ nullable: true }) secondaryColor!: string | null;
  @ApiProperty({ nullable: true }) accentColor!: string | null;
  @ApiProperty({ nullable: true }) zodiacSign!: string | null;
  @ApiProperty({ nullable: true }) chineseZodiac!: string | null;
  @ApiProperty() isDefault!: boolean;
  @ApiProperty() isActive!: boolean;
  @ApiProperty({ type: 'string', format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: 'string', format: 'date-time' }) updatedAt!: Date;
}

export class CompanionAssetPageDto extends PaginatedDto {
  @ApiProperty({ type: () => [CompanionAssetResponseDto] })
  items!: CompanionAssetResponseDto[];
}
