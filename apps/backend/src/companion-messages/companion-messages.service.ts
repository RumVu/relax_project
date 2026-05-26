import { Injectable } from '@nestjs/common';
import { CompanionMood, MessageTriggerType, MoodType } from '@prisma/client';
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

  async create(dto: CreateCompanionMessageDto) {
    const message = await this.prisma.companionMessage.create({ data: dto });
    await this.upsertSearchIndex(message);

    return message;
  }

  async update(id: string, dto: UpdateCompanionMessageDto) {
    await this.ensureExists(id);
    const message = await this.prisma.companionMessage.update({
      where: { id },
      data: dto,
    });
    await this.upsertSearchIndex(message);

    return message;
  }

  async remove(id: string) {
    await this.ensureExists(id);
    const message = await this.prisma.companionMessage.delete({
      where: { id },
    });
    await this.prisma.searchIndex.deleteMany({
      where: { entityType: 'COMPANION_MESSAGE', entityId: id },
    });

    return message;
  }

  private upsertSearchIndex(message: {
    id: string;
    content: string;
    triggerType: MessageTriggerType;
    mood: MoodType | null;
    companionMood: CompanionMood | null;
    minHour: number | null;
    maxHour: number | null;
    weight: number;
    isActive: boolean;
  }) {
    const hourRange =
      message.minHour === null && message.maxHour === null
        ? 'all-day'
        : `${message.minHour ?? 0}-${message.maxHour ?? 23}`;
    const payload = {
      title: this.truncate(message.content, 84),
      content: [
        message.content,
        message.triggerType,
        message.mood,
        message.companionMood,
        hourRange,
        `weight ${message.weight}`,
        message.isActive ? 'active' : 'draft',
      ]
        .filter(Boolean)
        .join(' '),
      tags: [
        'companion',
        'message',
        message.triggerType.toLowerCase(),
        message.mood?.toLowerCase(),
        message.companionMood?.toLowerCase(),
        hourRange,
        message.isActive ? 'active' : 'draft',
      ].filter((tag): tag is string => Boolean(tag)),
    };

    return this.prisma.searchIndex.upsert({
      where: {
        entityType_entityId: {
          entityType: 'COMPANION_MESSAGE',
          entityId: message.id,
        },
      },
      update: payload,
      create: {
        entityType: 'COMPANION_MESSAGE',
        entityId: message.id,
        ...payload,
      },
    });
  }

  private truncate(value: string, length: number) {
    return value.length <= length ? value : `${value.slice(0, length - 1)}...`;
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
