import { ArrayNotEmpty, IsArray, IsString } from 'class-validator';

export class RemoveStorageObjectDto {
  @IsArray()
  @ArrayNotEmpty()
  @IsString({ each: true })
  paths!: string[];
}
