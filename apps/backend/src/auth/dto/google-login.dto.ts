import { IsString, MinLength } from 'class-validator';

export class GoogleLoginDto {
  /**
   * Google ID token returned by Google Identity Services on the client
   * (the `credential` field of the CredentialResponse). Backend will
   * verify the signature against Google's public keys and check that
   * `aud` matches GOOGLE_CLIENT_ID before trusting the email.
   */
  @IsString()
  @MinLength(10)
  idToken!: string;
}
