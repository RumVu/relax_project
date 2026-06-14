import { IsIn, IsOptional, IsString } from 'class-validator';

export class ExportQueryDto {
  @IsOptional()
  @IsString()
  @IsIn(['json', 'csv'])
  format?: 'json' | 'csv';
}
