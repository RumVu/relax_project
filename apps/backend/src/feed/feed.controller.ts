import { Controller, Get, UseGuards, Req } from '@nestjs/common';
import { FeedService } from './feed.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('feed')
@UseGuards(JwtAuthGuard)
export class FeedController {
  constructor(private readonly feedService: FeedService) {}

  @Get()
  async getMyFeed(@Req() req) {
    return this.feedService.getFeed(req.user.id);
  }
}
