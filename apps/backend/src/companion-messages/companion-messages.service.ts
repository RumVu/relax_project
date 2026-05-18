import { Injectable } from '@nestjs/common';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { pickWeighted } from '../common/random';
import { PrismaService } from '../prisma/prisma.service';
import { CreateCompanionMessageDto } from './dto/create-companion-message.dto';
import { UpdateCompanionMessageDto } from './dto/update-companion-message.dto';

@Injectable()
export class CompanionMessagesService {
  constructor(private readonly prisma: PrismaService) {}

  findAll() {
    return this.prisma.companionMessage.findMany({
      orderBy: { createdAt: 'desc' },
    });
  }

  async findRandom() {
    const hour = new Date().getHours();
    const messages = await this.prisma.companionMessage.findMany({
      where: {
        isActive: true,
        OR: [
          { minHour: null, maxHour: null },
          { minHour: { lte: hour }, maxHour: { gte: hour } },
          { minHour: { lte: hour }, maxHour: null },
          { minHour: null, maxHour: { gte: hour } },
        ],
      },
    });
    const message = pickWeighted(messages);

    if (!message) {
      throw AppException.notFound(
        ErrorCode.CATALOG_ACTIVE_COMPANION_MESSAGE_NOT_FOUND,
        'Active companion message not found',
      );
    }

    return message;
  }

  create(dto: CreateCompanionMessageDto) {
    return this.prisma.companionMessage.create({ data: dto });
  }

  async update(id: string, dto: UpdateCompanionMessageDto) {
    await this.ensureExists(id);
    return this.prisma.companionMessage.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    await this.ensureExists(id);
    return this.prisma.companionMessage.delete({ where: { id } });
  }

  private async ensureExists(id: string) {
    const message = await this.prisma.companionMessage.findUnique({
      where: { id },
      select: { id: true },
    });

    if (!message) {
      throw AppException.notFound(
        ErrorCode.CATALOG_COMPANION_MESSAGE_NOT_FOUND,
        'Companion message not found',
      );
    }
  }
}
