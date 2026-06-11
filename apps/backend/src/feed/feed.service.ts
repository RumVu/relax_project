import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { FriendRequestStatus } from '@prisma/client';

@Injectable()
export class FeedService {
  constructor(private readonly prisma: PrismaService) {}

  async createEntry(
    userId: string,
    type: string,
    title: string,
    description?: string,
    relatedId?: string,
  ) {
    return this.prisma.feedEntry.create({
      data: {
        userId,
        type,
        title,
        description,
        relatedId,
      },
    });
  }

  async getFeed(userId: string) {
    const friendships = await this.prisma.friend.findMany({
      where: {
        OR: [
          { userId, status: FriendRequestStatus.ACCEPTED },
          { friendId: userId, status: FriendRequestStatus.ACCEPTED },
        ],
      },
      select: { userId: true, friendId: true },
    });

    const friendIds = friendships.map((f) =>
      f.userId === userId ? f.friendId : f.userId,
    );

    const userIds = [userId, ...friendIds];

    return this.prisma.feedEntry.findMany({
      where: {
        userId: { in: userIds },
      },
      orderBy: {
        createdAt: 'desc',
      },
      include: {
        user: {
          select: { id: true, name: true, avatar: true, email: true },
        },
      },
    });
  }
}
