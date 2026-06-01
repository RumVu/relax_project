import { IsString, MinLength, ValidateIf } from 'class-validator';

export class GoogleLoginDto {
  /**
   * Google ID token returned by Google Identity Services on the client
   * (the `credential` field of the CredentialResponse). Backend will
   * verify the signature against Google's public keys and check that
   * `aud` matches GOOGLE_CLIENT_ID before trusting the email.
   */
  @ValidateIf((dto: GoogleLoginDto) => !dto.accessToken)
  @IsString()
  @MinLength(10)
  idToken?: string;

  /**
   * OAuth access token returned by GIS token client. Used by the custom
   * web button so the UI can force Google's account chooser instead of
   * rendering a personalized iframe button.
   */
  @ValidateIf((dto: GoogleLoginDto) => !dto.idToken)
  @IsString()
  @MinLength(10)
  accessToken?: string;
}
