import { IsBoolean, IsOptional } from 'class-validator';

export class UpdatePrivacySettingsDto {
  @IsOptional()
  @IsBoolean()
  aiPrivacyMode?: boolean;
}
