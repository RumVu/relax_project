import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { CreateFeedbackDto } from './dto/create-feedback.dto';

@Injectable()
export class FeedbacksService {
  constructor(private readonly prisma: PrismaService) {}

  async create(userId: string | null, dto: CreateFeedbackDto) {
    return this.prisma.feedback.create({
      data: {
        userId,
        subject: dto.subject,
        message: dto.message,
        status: 'OPEN',
      },
    });
  }

  async findAll() {
    return this.prisma.feedback.findMany({
      orderBy: { createdAt: 'desc' },
      include: {
        user: {
          select: {
            id: true,
            email: true,
            name: true,
          },
        },
      },
    });
  }

  async updateStatus(id: string, status: string) {
    return this.prisma.feedback.update({
      where: { id },
      data: { status },
    });
  }
}
