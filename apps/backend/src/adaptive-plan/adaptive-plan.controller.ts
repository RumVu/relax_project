import { Controller, Get, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import type { AuthUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { AdaptivePlanService } from './adaptive-plan.service';

@ApiTags('Adaptive Plan')
@ApiBearerAuth('access-token')
@Controller('adaptive-plan')
export class AdaptivePlanController {
  constructor(private readonly service: AdaptivePlanService) {}

  @ApiOperation({ summary: 'Get personalized adaptive wellness plan' })
  @ApiOkResponse({
    description:
      'Adaptive plan with timing suggestions, activity priorities, notification adjustments.',
  })
  @UseGuards(JwtAuthGuard)
  @Get()
  getAdaptivePlan(@CurrentUser() user: AuthUser) {
    return this.service.generateAdaptivePlan(user.id);
  }

  @ApiOperation({ summary: 'Get behavioral insights' })
  @ApiOkResponse({
    description:
      'List of behavioral insights in Vietnamese based on user data patterns.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('insights')
  getInsights(@CurrentUser() user: AuthUser) {
    return this.service.getInsights(user.id);
  }
}
