import { Body, Controller, Get, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import type { AuthUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CreateSleepSessionDto } from './dto/create-sleep-session.dto';
import { SleepService } from './sleep.service';

@ApiTags('Sleep')
@ApiBearerAuth('access-token')
@Controller('sleep')
export class SleepController {
  constructor(private readonly sleepService: SleepService) {}

  @ApiOperation({ summary: 'Log a sleep session' })
  @UseGuards(JwtAuthGuard)
  @Post('sessions')
  createSession(
    @CurrentUser() user: AuthUser,
    @Body() dto: CreateSleepSessionDto,
  ) {
    return this.sleepService.createSession(user.id, dto);
  }

  @ApiOperation({ summary: 'Get current user sleep history' })
  @UseGuards(JwtAuthGuard)
  @Get('sessions/me')
  findSessions(@CurrentUser() user: AuthUser) {
    return this.sleepService.findSessions(user.id);
  }
}
