import { UserResponseDto } from '../../users/dto/user-response.dto';

export class AuthResponseDto {
  accessToken!: string;
  refreshToken!: string;
  expiresAt!: Date;
  sessionId?: string;
  user!: UserResponseDto;
}

/**
 * Shared shape for auth side-effect endpoints (logout, password reset,
 * email verification, account deletion). Fields are optional because each
 * action only returns the subset relevant to it.
 */
export class AuthActionResultDto {
  success?: boolean;
  mode?: string;
  revokedSessions?: boolean;
  anonymized?: boolean;
  devToken?: string;
  expiresAt?: Date;
  user?: UserResponseDto;
}
