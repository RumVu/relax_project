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
import { MoodRecoveryService } from './mood-recovery.service';

@ApiTags('Mood Recovery')
@ApiBearerAuth('access-token')
@Controller('mood-recovery')
@UseGuards(JwtAuthGuard)
export class MoodRecoveryController {
  constructor(private readonly recoveryService: MoodRecoveryService) {}

  @ApiOperation({ summary: 'Get mood recovery history (before/after sessions)' })
  @ApiOkResponse({ description: 'Recovery session list with deltas.' })
  @Get('me/history')
  getHistory(
    @CurrentUser() user: AuthUser,
    @Query('days') days?: string,
  ) {
    return this.recoveryService.getRecoveryHistory(
      user.id,
      days ? parseInt(days, 10) : 30,
    );
  }

  @ApiOperation({ summary: 'Get mood recovery summary analytics' })
  @ApiOkResponse({ description: 'Recovery summary with trends and best activity.' })
  @Get('me/summary')
  getSummary(
    @CurrentUser() user: AuthUser,
    @Query('days') days?: string,
  ) {
    return this.recoveryService.getRecoverySummary(
      user.id,
      days ? parseInt(days, 10) : 30,
    );
  }
}
