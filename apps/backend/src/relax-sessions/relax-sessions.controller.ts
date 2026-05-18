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
import { FinishRelaxSessionDto } from '../relax-activities/dto/finish-relax-session.dto';
import { RelaxActivityQueryDto } from '../relax-activities/dto/relax-activity-query.dto';
import { StartRelaxSessionDto } from '../relax-activities/dto/start-relax-session.dto';
import { RelaxActivitiesService } from '../relax-activities/relax-activities.service';

@ApiTags('Relax Sessions')
@ApiBearerAuth('access-token')
@Controller('relax-sessions')
export class RelaxSessionsController {
  constructor(
    private readonly relaxActivitiesService: RelaxActivitiesService,
  ) {}

  @ApiOperation({ summary: 'Start current user relax session' })
  @ApiCreatedResponse({ description: 'Started relax session.' })
  @UseGuards(JwtAuthGuard)
  @Post('start')
  start(@CurrentUser() user: AuthUser, @Body() dto: StartRelaxSessionDto) {
    return this.relaxActivitiesService.startSession(user.id, dto);
  }

  @ApiOperation({ summary: 'Finish current user relax session' })
  @ApiCreatedResponse({ description: 'Finished relax session.' })
  @UseGuards(JwtAuthGuard)
  @Post(':id/finish')
  finish(
    @CurrentUser() user: AuthUser,
    @Param('id') id: string,
    @Body() dto: FinishRelaxSessionDto,
  ) {
    return this.relaxActivitiesService.finishSession(user.id, id, dto);
  }

  @ApiOperation({ summary: 'List current user relax sessions' })
  @ApiOkResponse({ description: 'Finished relax sessions.' })
  @UseGuards(JwtAuthGuard)
  @Get('me')
  list(@CurrentUser() user: AuthUser, @Query() query: RelaxActivityQueryDto) {
    return this.relaxActivitiesService.listSessions(user.id, query);
  }

  @ApiOperation({ summary: 'Get current user relax session stats' })
  @ApiOkResponse({ description: 'Relax session stats.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/stats')
  stats(@CurrentUser() user: AuthUser, @Query() query: RelaxActivityQueryDto) {
    return this.relaxActivitiesService.getStats(user.id, query);
  }
}
