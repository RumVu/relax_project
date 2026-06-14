import { Body, Controller, Get, Post } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import { ContentService } from './content.service';
import { BulkImportCsvDto } from './dto/bulk-import-csv.dto';

@ApiTags('Content')
@Controller('content')
export class ContentController {
  constructor(private readonly contentService: ContentService) {}

  @ApiOperation({ summary: 'Bulk import quotes from CSV data' })
  @ApiOkResponse({ description: 'Import result with counts.' })
  @AdminOnly()
  @Post('import/quotes')
  importQuotes(@Body() dto: BulkImportCsvDto) {
    return this.contentService.bulkImportQuotes(dto.csvData);
  }

  @ApiOperation({ summary: 'Bulk import ambient sounds from CSV data' })
  @ApiOkResponse({ description: 'Import result with counts.' })
  @AdminOnly()
  @Post('import/sounds')
  importSounds(@Body() dto: BulkImportCsvDto) {
    return this.contentService.bulkImportSounds(dto.csvData);
  }

  @ApiOperation({ summary: 'Bulk import meditations from CSV data' })
  @ApiOkResponse({ description: 'Import result with counts.' })
  @AdminOnly()
  @Post('import/meditations')
  importMeditations(@Body() dto: BulkImportCsvDto) {
    return this.contentService.bulkImportMeditations(dto.csvData);
  }

  @ApiOperation({ summary: 'Get content statistics by type and status' })
  @ApiOkResponse({
    description: 'Content counts grouped by type and active/inactive.',
  })
  @AdminOnly()
  @Get('stats')
  getStats() {
    return this.contentService.getContentStats();
  }
}
