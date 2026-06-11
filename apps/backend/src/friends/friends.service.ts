import { Injectable, BadRequestException } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { FriendRequestStatus } from '@prisma/client';

@Injectable()
export class FriendsService {
  constructor(private readonly prisma: PrismaService) {}

  async sendRequest(userId: string, friendId: string) {
    if (userId === friendId) {
      throw new BadRequestException(
        'You cannot send a friend request to yourself',
      );
    }

    const friend = await this.prisma.user.findUnique({
      where: { id: friendId },
    });
    if (!friend) {
      throw new BadRequestException('User not found');
    }

    const existing = await this.prisma.friend.findFirst({
      where: {
        OR: [
          { userId, friendId },
          { userId: friendId, friendId: userId },
        ],
      },
    });

    if (existing) {
      throw new BadRequestException(
        'Friend request already sent or you are already friends',
      );
    }

    return this.prisma.friend.create({
      data: {
        userId,
        friendId,
        status: FriendRequestStatus.PENDING,
      },
    });
  }

  async acceptRequest(userId: string, requesterId: string) {
    const request = await this.prisma.friend.findUnique({
      where: {
        userId_friendId: {
          userId: requesterId,
          friendId: userId,
        },
      },
    });

    if (!request || request.status !== FriendRequestStatus.PENDING) {
      throw new BadRequestException('No pending friend request found');
    }

    return this.prisma.friend.update({
      where: {
        userId_friendId: {
          userId: requesterId,
          friendId: userId,
        },
      },
      data: {
        status: FriendRequestStatus.ACCEPTED,
        respondedAt: new Date(),
      },
    });
  }

  async listFriends(userId: string) {
    const friendships = await this.prisma.friend.findMany({
      where: {
        OR: [
          { userId, status: FriendRequestStatus.ACCEPTED },
          { friendId: userId, status: FriendRequestStatus.ACCEPTED },
        ],
      },
      include: {
        user: {
          select: { id: true, email: true, name: true, avatar: true },
        },
        friend: {
          select: { id: true, email: true, name: true, avatar: true },
        },
      },
    });

    return friendships.map((f) => {
      return f.userId === userId ? f.friend : f.user;
    });
  }

  async listPending(userId: string) {
    const requests = await this.prisma.friend.findMany({
      where: {
        friendId: userId,
        status: FriendRequestStatus.PENDING,
      },
      include: {
        user: {
          select: { id: true, email: true, name: true, avatar: true },
        },
      },
    });
    return requests.map((r) => r.user);
  }
}
