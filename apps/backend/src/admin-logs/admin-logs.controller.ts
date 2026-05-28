import { Controller, Get, Query } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import { AdminLogsService } from './admin-logs.service';
import { AdminLogQueryDto } from './dto/admin-log-query.dto';
import { AdminLogPageDto } from './dto/admin-log-response.dto';

@ApiTags('Admin Logs')
@Controller('admin-logs')
export class AdminLogsController {
  constructor(private readonly adminLogsService: AdminLogsService) {}

  @ApiOperation({
    summary: 'List admin audit logs',
  })
  @ApiOkResponse({
    type: AdminLogPageDto,
    description:
      'Paginated admin write-action audit trail with sanitized request details.',
  })
  @AdminOnly()
  @Get()
  findAll(@Query() query: AdminLogQueryDto) {
    return this.adminLogsService.findAll(query);
  }
}
