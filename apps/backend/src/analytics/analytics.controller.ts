import { Controller, Get, Query, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import type { AuthUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AnalyticsQueryDto } from './analytics-query.dto';
import { AnalyticsService } from './analytics.service';

@ApiTags('Analytics')
@ApiBearerAuth('access-token')
@Controller('analytics')
export class AnalyticsController {
  constructor(private readonly analyticsService: AnalyticsService) {}

  @ApiOperation({ summary: 'Get analytics response contracts for app charts' })
  @ApiOkResponse({
    description:
      'Stable chart/card contract for mood score, weekly stats, and dashboard analytics.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('contracts')
  getContracts() {
    return this.analyticsService.getContracts();
  }

  @ApiOperation({ summary: 'Get current user full analytics overview' })
  @ApiOkResponse({
    description:
      'Aggregated mood, journal, relax activity, and companion analytics.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me/overview')
  getOverview(
    @CurrentUser() user: AuthUser,
    @Query() query: AnalyticsQueryDto,
  ) {
    return this.analyticsService.getOverview(user.id, query);
  }
}
