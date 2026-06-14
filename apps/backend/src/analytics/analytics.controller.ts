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

  @ApiOperation({ summary: 'Get current user mood recovery score and stats' })
  @ApiOkResponse({
    description:
      'Mood recovery stats showing effectiveness of relax activities.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me/mood-recovery')
  getMoodRecovery(@CurrentUser() user: AuthUser) {
    return this.analyticsService.getMoodRecovery(user.id);
  }

  @ApiOperation({ summary: 'Get current user mood patterns analysis' })
  @ApiOkResponse({
    description: 'Mood patterns (by hour, weekday, trigger, activity).',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me/mood-patterns')
  getMoodPatterns(@CurrentUser() user: AuthUser) {
    return this.analyticsService.getMoodPatterns(user.id);
  }

  @ApiOperation({ summary: 'Get current user monthly mood calendar data' })
  @ApiOkResponse({ description: 'Monthly mood calendar data.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/mood-calendar')
  getMoodCalendar(@CurrentUser() user: AuthUser) {
    return this.analyticsService.getMoodCalendar(user.id);
  }

  @ApiOperation({
    summary: 'Get current user burnout or overload wellbeing signal',
  })
  @ApiOkResponse({ description: 'Wellbeing and burnout signals.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/burnout-signal')
  getBurnoutSignal(@CurrentUser() user: AuthUser) {
    return this.analyticsService.getBurnoutSignal(user.id);
  }

  @ApiOperation({ summary: 'Get current user mood forecast' })
  @ApiOkResponse({ description: 'Mood forecast and stress prediction.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/mood-forecast')
  getMoodForecast(@CurrentUser() user: AuthUser) {
    return this.analyticsService.getMoodForecast(user.id);
  }
}
