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
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { MoodGoalStatus } from '@prisma/client';
import type { AuthUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateMoodGoalDto } from './dto/create-mood-goal.dto';
import { UpdateMoodGoalDto } from './dto/update-mood-goal.dto';
import { MoodGoalsService } from './mood-goals.service';

@ApiTags('Mood Goals')
@ApiBearerAuth('access-token')
@Controller('mood-goals')
@UseGuards(JwtAuthGuard)
export class MoodGoalsController {
  constructor(private readonly moodGoalsService: MoodGoalsService) {}

  @ApiOperation({ summary: 'Create a mood goal' })
  @ApiCreatedResponse({ description: 'Created mood goal.' })
  @Post('me')
  create(@CurrentUser() user: AuthUser, @Body() dto: CreateMoodGoalDto) {
    return this.moodGoalsService.create(user.id, dto);
  }

  @ApiOperation({ summary: 'List current user mood goals' })
  @ApiOkResponse({ description: 'User mood goals list.' })
  @Get('me')
  findMine(
    @CurrentUser() user: AuthUser,
    @Query('status') status?: MoodGoalStatus,
  ) {
    return this.moodGoalsService.findByUser(user.id, status);
  }

  @ApiOperation({ summary: 'Get mood goals progress with live calculations' })
  @ApiOkResponse({ description: 'Active goals with progress.' })
  @Get('me/progress')
  getProgress(@CurrentUser() user: AuthUser) {
    return this.moodGoalsService.getProgress(user.id);
  }

  @ApiOperation({ summary: 'Get mood goals summary stats' })
  @ApiOkResponse({ description: 'Goals summary.' })
  @Get('me/summary')
  getSummary(@CurrentUser() user: AuthUser) {
    return this.moodGoalsService.getSummary(user.id);
  }

  @ApiOperation({ summary: 'Get a single mood goal' })
  @ApiOkResponse({ description: 'Mood goal detail.' })
  @Get('me/:id')
  findOne(@Param('id') id: string, @CurrentUser() user: AuthUser) {
    return this.moodGoalsService.findOne(id, user.id);
  }

  @ApiOperation({ summary: 'Update a mood goal' })
  @ApiOkResponse({ description: 'Updated mood goal.' })
  @Patch('me/:id')
  update(
    @Param('id') id: string,
    @CurrentUser() user: AuthUser,
    @Body() dto: UpdateMoodGoalDto,
  ) {
    return this.moodGoalsService.update(id, user.id, dto);
  }

  @ApiOperation({ summary: 'Delete a mood goal' })
  @ApiOkResponse({ description: 'Deleted mood goal.' })
  @Delete('me/:id')
  remove(@Param('id') id: string, @CurrentUser() user: AuthUser) {
    return this.moodGoalsService.remove(id, user.id);
  }
}
