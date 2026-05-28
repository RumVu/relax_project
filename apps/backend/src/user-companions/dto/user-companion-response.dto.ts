import {
  CompanionAction,
  CompanionMood,
  CompanionPersonalizationMode,
  CompanionType,
} from '@prisma/client';
import { CompanionAssetResponseDto } from '../../companion-assets/dto/companion-asset-response.dto';

export class UserCompanionResponseDto {
  id!: string;
  userId!: string;
  assetId!: string | null;
  name!: string;
  type!: CompanionType;
  personalizationMode!: CompanionPersonalizationMode;
  mood!: CompanionMood;
  action!: CompanionAction;
  level!: number;
  affection!: number;
  energy!: number;
  lastSeenAt!: Date | null;
  lastFedAt!: Date | null;
  lastMoodAt!: Date | null;
  createdAt!: Date;
  updatedAt!: Date;
  asset?: CompanionAssetResponseDto | null;
}
