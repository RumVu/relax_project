import { AuthProvider, UserRole } from '@prisma/client';
import { PaginatedDto } from '../../common/dto/paginated.dto';
import { UserPreferenceResponseDto } from '../../user-preferences/dto/user-preference-response.dto';
import { UserProfileResponseDto } from '../../user-profiles/dto/user-profile-response.dto';

export class TierNameDto {
  name!: string;
}

export class UserSubscriptionSummaryDto {
  id!: string;
  planName!: string;
  status!: string;
  endDate!: Date | null;
  tier?: TierNameDto | null;
}

export class UserResponseDto {
  id!: string;
  email!: string;
  name!: string | null;
  avatar!: string | null;
  role!: UserRole;
  authProvider!: AuthProvider;
  emailVerified!: boolean;
  isActive!: boolean;
  lastLoginAt!: Date | null;
  deletedAt!: Date | null;
  createdAt!: Date;
  updatedAt!: Date;
  profile?: UserProfileResponseDto | null;
  preferences?: UserPreferenceResponseDto | null;
  subscriptions?: UserSubscriptionSummaryDto[];
}

export class UserPageDto extends PaginatedDto {
  items!: UserResponseDto[];
}
