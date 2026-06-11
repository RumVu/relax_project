import { Controller, Get, Post, Param, UseGuards, Req } from '@nestjs/common';
import { FriendsService } from './friends.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';

@Controller('friends')
@UseGuards(JwtAuthGuard)
export class FriendsController {
  constructor(private readonly friendsService: FriendsService) {}

  @Post('request/:friendId')
  async sendRequest(@Req() req, @Param('friendId') friendId: string) {
    return this.friendsService.sendRequest(req.user.id, friendId);
  }

  @Post('accept/:requesterId')
  async acceptRequest(@Req() req, @Param('requesterId') requesterId: string) {
    return this.friendsService.acceptRequest(req.user.id, requesterId);
  }

  @Get('me')
  async getMyFriends(@Req() req) {
    return this.friendsService.listFriends(req.user.id);
  }

  @Get('pending')
  async getPendingRequests(@Req() req) {
    return this.friendsService.listPending(req.user.id);
  }
}
