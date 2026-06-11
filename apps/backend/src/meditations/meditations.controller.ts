import { Body, Controller, Get, Post, Query, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import type { AuthUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateMeditationSessionDto } from './dto/create-meditation-session.dto';
import { MeditationsService } from './meditations.service';

@ApiTags('Meditations')
@ApiBearerAuth('access-token')
@Controller('meditations')
export class MeditationsController {
  constructor(private readonly meditationsService: MeditationsService) {}

  @ApiOperation({ summary: 'Get active guided meditations' })
  @Get('guides')
  findGuides(
    @Query('difficulty') difficulty?: string,
    @Query('focusArea') focusArea?: string,
  ) {
    return this.meditationsService.findGuides(difficulty, focusArea);
  }

  @ApiOperation({ summary: 'Log a meditation session' })
  @UseGuards(JwtAuthGuard)
  @Post('sessions')
  createSession(
    @CurrentUser() user: AuthUser,
    @Body() dto: CreateMeditationSessionDto,
  ) {
    return this.meditationsService.createSession(user.id, dto);
  }

  @ApiOperation({ summary: 'Get current user meditation sessions history' })
  @UseGuards(JwtAuthGuard)
  @Get('sessions/me')
  findSessions(@CurrentUser() user: AuthUser) {
    return this.meditationsService.findSessions(user.id);
  }
}
