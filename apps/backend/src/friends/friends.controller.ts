import { Controller, Get, Post, Param, UseGuards } from '@nestjs/common';
import { FriendsService } from './friends.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { AuthUser } from '../auth/auth.types';

@Controller('friends')
@UseGuards(JwtAuthGuard)
export class FriendsController {
  constructor(private readonly friendsService: FriendsService) {}

  @Post('request/:friendId')
  async sendRequest(
    @CurrentUser() user: AuthUser,
    @Param('friendId') friendId: string,
  ) {
    return this.friendsService.sendRequest(user.id, friendId);
  }

  @Post('accept/:requesterId')
  async acceptRequest(
    @CurrentUser() user: AuthUser,
    @Param('requesterId') requesterId: string,
  ) {
    return this.friendsService.acceptRequest(user.id, requesterId);
  }

  @Get('me')
  async getMyFriends(@CurrentUser() user: AuthUser) {
    return this.friendsService.listFriends(user.id);
  }

  @Get('pending')
  async getPendingRequests(@CurrentUser() user: AuthUser) {
    return this.friendsService.listPending(user.id);
  }
}
