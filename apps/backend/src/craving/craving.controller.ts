import {
  Body,
  Controller,
  Get,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
import type { AuthUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CravingService } from './craving.service';
import { LogCravingDto } from './dto/log-craving.dto';
import { UpdateGoalDto } from './dto/update-goal.dto';

@ApiTags('Craving')
@ApiBearerAuth('access-token')
@Controller('craving')
export class CravingController {
  constructor(private readonly cravingService: CravingService) {}

  @ApiOperation({ summary: 'Log a stress break event' })
  @ApiCreatedResponse({ description: 'Stress break log created.' })
  @UseGuards(JwtAuthGuard)
  @Post('log')
  logCraving(@CurrentUser() user: AuthUser, @Body() dto: LogCravingDto) {
    return this.cravingService.logCraving(user.id, dto);
  }

  @ApiOperation({ summary: 'Get stress break history' })
  @ApiOkResponse({ description: 'Stress break history list.' })
  @ApiQuery({ name: 'days', required: false, example: 30 })
  @UseGuards(JwtAuthGuard)
  @Get('history')
  getCravingHistory(
    @CurrentUser() user: AuthUser,
    @Query('days') days?: string,
  ) {
    const numDays = days ? parseInt(days, 10) : undefined;
    return this.cravingService.getCravingHistory(
      user.id,
      numDays && !isNaN(numDays) ? numDays : undefined,
    );
  }

  @ApiOperation({ summary: 'Get stress break analytics / stats' })
  @ApiOkResponse({
    description:
      'Stress break stats with hourly distribution, triggers, activities.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('stats')
  getCravingStats(@CurrentUser() user: AuthUser) {
    return this.cravingService.getCravingStats(user.id);
  }

  @ApiOperation({ summary: 'Get break goals' })
  @ApiOkResponse({ description: 'Current break goals.' })
  @UseGuards(JwtAuthGuard)
  @Get('goal')
  getGoal(@CurrentUser() user: AuthUser) {
    return this.cravingService.getOrCreateGoal(user.id);
  }

  @ApiOperation({ summary: 'Update break goals' })
  @ApiOkResponse({ description: 'Updated break goals.' })
  @UseGuards(JwtAuthGuard)
  @Patch('goal')
  updateGoal(@CurrentUser() user: AuthUser, @Body() dto: UpdateGoalDto) {
    return this.cravingService.updateGoal(user.id, dto);
  }
}
