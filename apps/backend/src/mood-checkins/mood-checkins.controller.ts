import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiForbiddenResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { MoodType, UserRole } from '@prisma/client';
import type { AuthUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { CreateMoodCheckinDto } from './dto/create-mood-checkin.dto';
import { MoodAnalyticsQueryDto } from './dto/mood-analytics-query.dto';
import { MoodCheckinQueryDto } from './dto/mood-checkin-query.dto';
import { RecalculateWeeklyMoodStatsDto } from './dto/recalculate-weekly-mood-stats.dto';
import { UpdateMoodCheckinDto } from './dto/update-mood-checkin.dto';
import { MoodCheckinsService } from './mood-checkins.service';

@ApiTags('Mood Check-ins')
@ApiBearerAuth('access-token')
@Controller('mood-checkins')
export class MoodCheckinsController {
  constructor(private readonly moodCheckinsService: MoodCheckinsService) {}

  @ApiOperation({ summary: 'List mood options for the mood onboarding screen' })
  @ApiOkResponse({ description: 'Mood option metadata.' })
  @Get('options')
  getOptions() {
    return this.moodCheckinsService.getOptions();
  }

  @ApiOperation({ summary: 'List all mood check-ins (admin)' })
  @ApiOkResponse({ description: 'Mood check-in list.' })
  @ApiForbiddenResponse({ description: 'Requires ADMIN role.' })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Get()
  findAll(@Query() query: MoodCheckinQueryDto) {
    return this.moodCheckinsService.findAll(query);
  }

  @ApiOperation({ summary: 'List current user mood check-ins' })
  @ApiOkResponse({ description: 'Current user mood check-in list.' })
  @UseGuards(JwtAuthGuard)
  @Get('me')
  findMine(@CurrentUser() user: AuthUser, @Query() query: MoodCheckinQueryDto) {
    return this.moodCheckinsService.findByUserId(user.id, query);
  }

  @ApiOperation({ summary: 'Get current user latest mood check-in' })
  @ApiOkResponse({ description: 'Latest current user mood check-in.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/latest')
  findMineLatest(@CurrentUser() user: AuthUser) {
    return this.moodCheckinsService.findLatest(user.id);
  }

  @ApiOperation({ summary: 'Get current user mood statistics' })
  @ApiOkResponse({ description: 'Current user mood stats and streaks.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/stats')
  getMineStats(
    @CurrentUser() user: AuthUser,
    @Query() query: MoodCheckinQueryDto,
  ) {
    return this.moodCheckinsService.getStats(user.id, query);
  }

  @ApiOperation({ summary: 'Get current user materialized weekly mood stats' })
  @ApiOkResponse({ description: 'Current user weekly mood stat rows.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/weekly-stats')
  getMineWeeklyStats(
    @CurrentUser() user: AuthUser,
    @Query() query: MoodCheckinQueryDto,
  ) {
    return this.moodCheckinsService.getWeeklyStats(user.id, query);
  }

  @ApiOperation({
    summary: 'Recalculate current user materialized weekly mood stats',
  })
  @ApiOkResponse({
    description:
      'Recalculated weekly mood stat rows from mood score dates and timezone.',
  })
  @UseGuards(JwtAuthGuard)
  @Post('me/weekly-stats/recalculate')
  recalculateMineWeeklyStats(
    @CurrentUser() user: AuthUser,
    @Body() dto: RecalculateWeeklyMoodStatsDto,
  ) {
    return this.moodCheckinsService.recalculateWeeklyStats(user.id, dto);
  }

  @ApiOperation({ summary: 'Get current user mood analytics timeline' })
  @ApiOkResponse({
    description:
      'Mood analytics by day with summary, previous-period comparison, deltas, and insights.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me/analytics')
  getMineAnalytics(
    @CurrentUser() user: AuthUser,
    @Query() query: MoodAnalyticsQueryDto,
  ) {
    return this.moodCheckinsService.getAnalytics(user.id, query);
  }

  @ApiOperation({ summary: 'Get current user mood dashboard' })
  @ApiOkResponse({
    description:
      'Home mood dashboard with options, latest check-in, distribution, streaks, and recommendations.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me/dashboard')
  getMineDashboard(
    @CurrentUser() user: AuthUser,
    @Query() query: MoodCheckinQueryDto,
  ) {
    return this.moodCheckinsService.getDashboard(user.id, query);
  }

  @ApiOperation({ summary: 'Get recommended relax actions for a mood' })
  @ApiOkResponse({ description: 'Recommended actions for the selected mood.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/recommendations')
  getMineRecommendations(@Query('mood') mood?: MoodType) {
    return this.moodCheckinsService.getRecommendations(mood);
  }

  @ApiOperation({ summary: 'Create current user mood check-in' })
  @ApiCreatedResponse({ description: 'Created mood check-in.' })
  @UseGuards(JwtAuthGuard)
  @Post('me')
  createMine(@CurrentUser() user: AuthUser, @Body() dto: CreateMoodCheckinDto) {
    return this.moodCheckinsService.create(user.id, dto);
  }

  @ApiOperation({ summary: 'List mood check-ins by user id (admin)' })
  @ApiOkResponse({ description: 'User mood check-in list.' })
  @ApiForbiddenResponse({ description: 'Requires ADMIN role.' })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Get('user/:userId')
  findByUserId(
    @Param('userId') userId: string,
    @Query() query: MoodCheckinQueryDto,
  ) {
    return this.moodCheckinsService.findByUserId(userId, query);
  }

  @ApiOperation({ summary: 'Get mood statistics by user id (admin)' })
  @ApiOkResponse({ description: 'User mood stats and streaks.' })
  @ApiForbiddenResponse({ description: 'Requires ADMIN role.' })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Get('user/:userId/stats')
  getStatsByUserId(
    @Param('userId') userId: string,
    @Query() query: MoodCheckinQueryDto,
  ) {
    return this.moodCheckinsService.getStats(userId, query);
  }

  @ApiOperation({
    summary: 'Get materialized weekly mood stats by user id (admin)',
  })
  @ApiOkResponse({ description: 'User weekly mood stat rows.' })
  @ApiForbiddenResponse({ description: 'Requires ADMIN role.' })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Get('user/:userId/weekly-stats')
  getWeeklyStatsByUserId(
    @Param('userId') userId: string,
    @Query() query: MoodCheckinQueryDto,
  ) {
    return this.moodCheckinsService.getWeeklyStats(userId, query);
  }

  @ApiOperation({
    summary: 'Recalculate weekly mood stats by user id (admin)',
  })
  @ApiOkResponse({
    description: 'Admin recalculation result for user weekly mood stat rows.',
  })
  @ApiForbiddenResponse({ description: 'Requires ADMIN role.' })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Post('user/:userId/weekly-stats/recalculate')
  recalculateWeeklyStatsByUserId(
    @Param('userId') userId: string,
    @Body() dto: RecalculateWeeklyMoodStatsDto,
  ) {
    return this.moodCheckinsService.recalculateWeeklyStats(userId, dto);
  }

  @ApiOperation({ summary: 'Get mood analytics by user id (admin)' })
  @ApiOkResponse({ description: 'User mood analytics timeline.' })
  @ApiForbiddenResponse({ description: 'Requires ADMIN role.' })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Get('user/:userId/analytics')
  getAnalyticsByUserId(
    @Param('userId') userId: string,
    @Query() query: MoodAnalyticsQueryDto,
  ) {
    return this.moodCheckinsService.getAnalytics(userId, query);
  }

  @ApiOperation({ summary: 'Get one mood check-in by id' })
  @ApiOkResponse({ description: 'Mood check-in payload.' })
  @UseGuards(JwtAuthGuard)
  @Get(':id')
  findOne(@Param('id') id: string, @CurrentUser() user: AuthUser) {
    return this.moodCheckinsService.findOne(id, user);
  }

  @ApiOperation({ summary: 'Update one mood check-in by id' })
  @ApiOkResponse({ description: 'Updated mood check-in payload.' })
  @UseGuards(JwtAuthGuard)
  @Patch(':id')
  update(
    @Param('id') id: string,
    @Body() dto: UpdateMoodCheckinDto,
    @CurrentUser() user: AuthUser,
  ) {
    return this.moodCheckinsService.update(id, dto, user);
  }

  @ApiOperation({ summary: 'Delete one mood check-in by id' })
  @ApiOkResponse({ description: 'Deleted mood check-in payload.' })
  @UseGuards(JwtAuthGuard)
  @Delete(':id')
  remove(@Param('id') id: string, @CurrentUser() user: AuthUser) {
    return this.moodCheckinsService.remove(id, user);
  }
}
