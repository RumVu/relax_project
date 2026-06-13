import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import type { AuthUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RecommendationsService } from './recommendations.service';
import { RateContentDto } from './dto/rate-content.dto';

@ApiTags('Recommendations')
@ApiBearerAuth('access-token')
@Controller('recommendations')
export class RecommendationsController {
  constructor(private readonly service: RecommendationsService) {}

  @ApiOperation({
    summary: 'Get today smart recommendations for current user',
  })
  @ApiOkResponse({
    description:
      'Smart recommendations based on mood, history, time, triggers.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me/today')
  getToday(@CurrentUser() user: AuthUser) {
    return this.service.getTodayRecommendations(user.id);
  }

  @ApiOperation({ summary: 'Refresh recommendations for current user' })
  @ApiOkResponse({ description: 'Fresh recommendations regenerated.' })
  @UseGuards(JwtAuthGuard)
  @Post('me/refresh')
  refresh(@CurrentUser() user: AuthUser) {
    return this.service.refreshRecommendations(user.id);
  }

  @ApiOperation({ summary: 'Rate a content item' })
  @ApiOkResponse({ description: 'Content rating saved.' })
  @UseGuards(JwtAuthGuard)
  @Post('content-ratings')
  rateContent(@CurrentUser() user: AuthUser, @Body() dto: RateContentDto) {
    return this.service.rateContent(user.id, dto);
  }

  @ApiOperation({ summary: 'Get my content ratings' })
  @ApiOkResponse({ description: 'User content ratings.' })
  @UseGuards(JwtAuthGuard)
  @Get('content-ratings/me')
  getMyRatings(@CurrentUser() user: AuthUser) {
    return this.service.getMyRatings(user.id);
  }

  @ApiOperation({ summary: 'Get trigger analytics for current user' })
  @ApiOkResponse({
    description: 'Trigger frequency and effective activities.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me/trigger-analytics')
  getTriggerAnalytics(@CurrentUser() user: AuthUser) {
    return this.service.getTriggerAnalytics(user.id);
  }
}
