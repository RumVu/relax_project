import { Body, Controller, Get, Param, Post, UseGuards } from '@nestjs/common';
import { BuddyCircleService } from './buddy-circle.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { AuthUser } from '../auth/auth.types';
import { StartGroupChallengeDto } from './dto/start-group-challenge.dto';

@Controller('buddy-circle')
@UseGuards(JwtAuthGuard)
export class BuddyCircleController {
  constructor(private readonly buddyCircleService: BuddyCircleService) {}

  @Get()
  async getMyCircle(@CurrentUser() user: AuthUser) {
    return this.buddyCircleService.getMyCircle(user.id);
  }

  @Post('nudge/:friendId')
  async sendNudge(
    @CurrentUser() user: AuthUser,
    @Param('friendId') friendId: string,
  ) {
    return this.buddyCircleService.sendNudge(user.id, friendId);
  }

  @Get('feed')
  async getCircleFeed(@CurrentUser() user: AuthUser) {
    return this.buddyCircleService.getCircleFeed(user.id);
  }

  @Post('challenge')
  async startGroupChallenge(
    @CurrentUser() user: AuthUser,
    @Body() dto: StartGroupChallengeDto,
  ) {
    return this.buddyCircleService.startGroupChallenge(user.id, dto);
  }

  @Get('stats')
  async getCircleStats(@CurrentUser() user: AuthUser) {
    return this.buddyCircleService.getCircleStats(user.id);
  }

  @Post('share-mood')
  async shareMood(@CurrentUser() user: AuthUser) {
    return this.buddyCircleService.shareMood(user.id);
  }

  @Post('feed/:entryId/react')
  async reactToFeed(
    @CurrentUser() user: AuthUser,
    @Param('entryId') entryId: string,
    @Body('emoji') emoji: string,
  ) {
    return this.buddyCircleService.reactToFeed(user.id, entryId, emoji ?? '❤️');
  }
}
