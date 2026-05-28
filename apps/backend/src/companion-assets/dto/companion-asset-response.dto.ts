import { CompanionType } from '@prisma/client';
import { PaginatedDto } from '../../common/dto/paginated.dto';

export class CompanionAssetResponseDto {
  id!: string;
  name!: string;
  type!: CompanionType;
  description!: string | null;
  previewImageUrl!: string | null;
  spriteSheetUrl!: string | null;
  idleAnimationUrl!: string | null;
  sleepAnimationUrl!: string | null;
  walkAnimationUrl!: string | null;
  primaryColor!: string | null;
  secondaryColor!: string | null;
  accentColor!: string | null;
  zodiacSign!: string | null;
  chineseZodiac!: string | null;
  isDefault!: boolean;
  isActive!: boolean;
  createdAt!: Date;
  updatedAt!: Date;
}

export class CompanionAssetPageDto extends PaginatedDto {
  items!: CompanionAssetResponseDto[];
}
