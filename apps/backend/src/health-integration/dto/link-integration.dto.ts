import { IsString } from 'class-validator';

export class LinkIntegrationDto {
  @IsString()
  type!: string;
}
