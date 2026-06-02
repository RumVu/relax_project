import { IsOptional, IsString, MinLength, ValidateIf } from 'class-validator';

export class GoogleLoginDto {
  /**
   * Legacy GIS ID token. Kept for backwards compatibility.
   */
  @ValidateIf(
    (dto: GoogleLoginDto) => !dto.accessToken && !dto.authorizationCode,
  )
  @IsString()
  @MinLength(10)
  idToken?: string;

  /**
   * Legacy OAuth access token. Kept for backwards compatibility.
   */
  @ValidateIf((dto: GoogleLoginDto) => !dto.idToken && !dto.authorizationCode)
  @IsString()
  @MinLength(10)
  accessToken?: string;

  /**
   * OAuth authorization code returned to /auth/google/callback.
   * Backend exchanges this using GOOGLE_CLIENT_SECRET.
   */
  @ValidateIf((dto: GoogleLoginDto) => !dto.idToken && !dto.accessToken)
  @IsString()
  @MinLength(10)
  authorizationCode?: string;

  @IsOptional()
  @IsString()
  redirectUri?: string;
}
