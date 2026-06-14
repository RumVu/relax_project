import { Controller, Get, Post, Body, Query } from '@nestjs/common';
import { ApiOkResponse, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import { AdminDashboardService } from './admin-dashboard.service';
import { AdminDashboardQueryDto } from './dto/admin-dashboard-query.dto';
import { AdminSearchQueryDto } from './dto/admin-search-query.dto';

type PromptsConfig = Record<string, string>;

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

  @ApiOperation({ summary: 'Get current AI prompts config (admin)' })
  @ApiOkResponse({ description: 'AI prompts configuration.' })
  @AdminOnly()
  @Get('prompts')
  getPrompts(): PromptsConfig {
    return this.adminDashboardService.getPrompts();
  }

  @ApiOperation({ summary: 'Update AI prompts config (admin)' })
  @ApiOkResponse({ description: 'AI prompts configuration updated.' })
  @AdminOnly()
  @Post('prompts')
  updatePrompts(@Body() prompts: Record<string, string>) {
    return this.adminDashboardService.updatePrompts(prompts);
  }

  @ApiOperation({ summary: 'Get content quality review metrics (admin)' })
  @ApiOkResponse({
    description: 'Content quality metrics (popular, highly rated).',
  })
  @AdminOnly()
  @Get('content-quality')
  getContentQuality() {
    return this.adminDashboardService.getContentQuality();
  }
}
