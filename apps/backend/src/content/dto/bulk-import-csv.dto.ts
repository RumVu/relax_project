import { IsString, MaxLength, MinLength } from 'class-validator';
import { MAX_CSV_LENGTH } from '../content.service';

export class BulkImportCsvDto {
  @IsString()
  @MinLength(10)
  @MaxLength(MAX_CSV_LENGTH)
  csvData!: string;
}
