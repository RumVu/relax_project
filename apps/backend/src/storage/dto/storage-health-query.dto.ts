import { Transform } from 'class-transformer';
import { IsBoolean, IsOptional } from 'class-validator';

export class StorageHealthQueryDto {
  @IsOptional()
  @Transform(({ value }) => value === true || value === 'true')
  @IsBoolean()
  deep?: boolean;
}
