import { ApiProperty } from '@nestjs/swagger';
import { AuthProvider, UserRole } from '@prisma/client';
import { PaginatedDto } from '../../common/dto/paginated.dto';
import { UserPreferenceResponseDto } from '../../user-preferences/dto/user-preference-response.dto';
import { UserProfileResponseDto } from '../../user-profiles/dto/user-profile-response.dto';

export class TierNameDto {
  @ApiProperty() name!: string;
}

export class UserSubscriptionSummaryDto {
  @ApiProperty() id!: string;
  @ApiProperty() planName!: string;
  @ApiProperty() status!: string;
  @ApiProperty({ nullable: true, type: 'string', format: 'date-time' })
  endDate!: Date | null;
  @ApiProperty({ type: () => TierNameDto, nullable: true, required: false })
  tier?: TierNameDto | null;
}

export class UserResponseDto {
  @ApiProperty() id!: string;
  @ApiProperty() email!: string;
  @ApiProperty({ nullable: true }) name!: string | null;
  @ApiProperty({ nullable: true }) avatar!: string | null;
  @ApiProperty({ enum: UserRole }) role!: UserRole;
  @ApiProperty({ enum: AuthProvider }) authProvider!: AuthProvider;
  @ApiProperty() emailVerified!: boolean;
  @ApiProperty() isActive!: boolean;
  @ApiProperty({ nullable: true, type: 'string', format: 'date-time' })
  lastLoginAt!: Date | null;
  @ApiProperty({ nullable: true, type: 'string', format: 'date-time' })
  deletedAt!: Date | null;
  @ApiProperty({ type: 'string', format: 'date-time' }) createdAt!: Date;
  @ApiProperty({ type: 'string', format: 'date-time' }) updatedAt!: Date;
  @ApiProperty({
    type: () => UserProfileResponseDto,
    nullable: true,
    required: false,
  })
  profile?: UserProfileResponseDto | null;
  @ApiProperty({
    type: () => UserPreferenceResponseDto,
    nullable: true,
    required: false,
  })
  preferences?: UserPreferenceResponseDto | null;
  @ApiProperty({ type: () => [UserSubscriptionSummaryDto], required: false })
  subscriptions?: UserSubscriptionSummaryDto[];
}

export class UserPageDto extends PaginatedDto {
  @ApiProperty({ type: () => [UserResponseDto] }) items!: UserResponseDto[];
}
