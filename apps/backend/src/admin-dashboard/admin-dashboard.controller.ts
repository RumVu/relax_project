import { Controller, Get, Query } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import { AdminDashboardService } from './admin-dashboard.service';
import { AdminDashboardQueryDto } from './dto/admin-dashboard-query.dto';
import { AdminSearchQueryDto } from './dto/admin-search-query.dto';

@ApiTags('Admin Dashboard')
@Controller('admin')
export class AdminDashboardController {
  constructor(private readonly adminDashboardService: AdminDashboardService) {}

  @ApiOperation({
    summary:
      'Get admin aggregate dashboard metrics for users, billing, retention, engagement, and operations',
  })
  @ApiOkResponse({
    description:
      'Admin dashboard aggregate payload: DAU/WAU/MAU, revenue, subscriptions, mood, relax, push, companion CTR, and timeline.',
  })
  @AdminOnly()
  @Get('analytics/overview')
  getOverview(@Query() query: AdminDashboardQueryDto) {
    return this.adminDashboardService.getOverview(query);
  }

  @ApiOperation({ summary: 'Search indexed dashboard/admin content' })
  @ApiOkResponse({
    description:
      'SearchIndex results for dashboard global search. Blank query returns latest indexes; non-empty query requires at least 2 characters.',
  })
  @AdminOnly()
  @Get('search')
  search(@Query() query: AdminSearchQueryDto) {
    return this.adminDashboardService.search(query);
  }
}
