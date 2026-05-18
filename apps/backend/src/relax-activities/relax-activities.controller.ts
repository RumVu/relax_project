import {
  Body,
  Controller,
  Get,
  Param,
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
import type { AuthUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { FinishRelaxSessionDto } from './dto/finish-relax-session.dto';
import { RelaxActivityQueryDto } from './dto/relax-activity-query.dto';
import { StartRelaxSessionDto } from './dto/start-relax-session.dto';
import { RelaxActivitiesService } from './relax-activities.service';

@ApiTags('Relax Activities')
@ApiBearerAuth('access-token')
@Controller('relax-activities')
export class RelaxActivitiesController {
  constructor(
    private readonly relaxActivitiesService: RelaxActivitiesService,
  ) {}

  @ApiOperation({ summary: 'List relax activity options' })
  @ApiOkResponse({
    description: 'Relax activity options with linked resources.',
  })
  @Get()
  getActivities() {
    return this.relaxActivitiesService.getActivities();
  }

  @ApiOperation({ summary: 'Start current user relax activity session' })
  @ApiCreatedResponse({ description: 'Started relax session.' })
  @UseGuards(JwtAuthGuard)
  @Post('sessions/start')
  startSession(
    @CurrentUser() user: AuthUser,
    @Body() dto: StartRelaxSessionDto,
  ) {
    return this.relaxActivitiesService.startSession(user.id, dto);
  }

  @ApiOperation({ summary: 'Finish current user relax activity session' })
  @ApiCreatedResponse({
    description: 'Finished relax session and post-check-in payload.',
  })
  @UseGuards(JwtAuthGuard)
  @Post('sessions/:id/finish')
  finishSession(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Body() dto: FinishRelaxSessionDto,
  ) {
    return this.relaxActivitiesService.finishSession(user.id, id, dto);
  }

  @ApiOperation({ summary: 'List current user finished relax sessions' })
  @ApiOkResponse({ description: 'Finished relax session list.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/sessions')
  listSessions(
    @CurrentUser() user: AuthUser,
    @Query() query: RelaxActivityQueryDto,
  ) {
    return this.relaxActivitiesService.listSessions(user.id, query);
  }

  @ApiOperation({ summary: 'Get current user relax statistics' })
  @ApiOkResponse({
    description:
      'Relax statistics with streak, total time, favorite activities, timeline, and recent moments.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me/stats')
  getStats(
    @CurrentUser() user: AuthUser,
    @Query() query: RelaxActivityQueryDto,
  ) {
    return this.relaxActivitiesService.getStats(user.id, query);
  }
}
