import { IsObject, IsOptional, IsString, MaxLength } from 'class-validator';

export class CreateCompanionInteractionDto {
  @IsString()
  @MaxLength(80)
  type!: string;

  @IsOptional()
  @IsObject()
  metadata?: Record<string, unknown>;
}
