import { IsString, MinLength } from 'class-validator';

export class BulkImportCsvDto {
  @IsString()
  @MinLength(10)
  csvData!: string;
}
