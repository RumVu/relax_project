import { Injectable } from '@nestjs/common';
import { MoodType } from '@prisma/client';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { PrismaService } from '../prisma/prisma.service';
import { CreateCozyQuoteDto } from './dto/create-cozy-quote.dto';
import { UpdateCozyQuoteDto } from './dto/update-cozy-quote.dto';

@Injectable()
export class CozyQuotesService {
  constructor(private readonly prisma: PrismaService) {}

  findAll() {
    return this.prisma.cozyQuote.findMany({
      orderBy: { createdAt: 'desc' },
    });
  }

  async findRandom() {
    const count = await this.prisma.cozyQuote.count({
      where: { isActive: true },
    });

    if (count === 0) {
      throw AppException.notFound(
        ErrorCode.CATALOG_ACTIVE_COZY_QUOTE_NOT_FOUND,
        'Active cozy quote not found',
      );
    }

    const [quote] = await this.prisma.cozyQuote.findMany({
      where: { isActive: true },
      skip: Math.floor(Math.random() * count),
      take: 1,
    });

    return quote;
  }

  findByMood(mood: MoodType) {
    return this.prisma.cozyQuote.findMany({
      where: { mood },
      orderBy: { createdAt: 'desc' },
    });
  }

  async create(dto: CreateCozyQuoteDto) {
    const quote = await this.prisma.cozyQuote.create({ data: dto });
    await this.upsertSearchIndex(quote);

    return quote;
  }

  async update(id: string, dto: UpdateCozyQuoteDto) {
    await this.ensureExists(id);
    const quote = await this.prisma.cozyQuote.update({
      where: { id },
      data: dto,
    });
    await this.upsertSearchIndex(quote);

    return quote;
  }

  async remove(id: string) {
    await this.ensureExists(id);
    const quote = await this.prisma.cozyQuote.delete({ where: { id } });
    await this.prisma.searchIndex.deleteMany({
      where: { entityType: 'COZY_QUOTE', entityId: id },
    });

    return quote;
  }

  private upsertSearchIndex(quote: {
    id: string;
    content: string;
    author: string | null;
    mood: MoodType | null;
    isActive: boolean;
  }) {
    return this.prisma.searchIndex.upsert({
      where: {
        entityType_entityId: {
          entityType: 'COZY_QUOTE',
          entityId: quote.id,
        },
      },
      update: {
        title: this.truncate(quote.content, 84),
        content: [
          quote.content,
          quote.author,
          quote.mood,
          quote.isActive ? 'active' : 'draft',
        ]
          .filter(Boolean)
          .join(' '),
        tags: [
          'quote',
          'cozy',
          quote.mood?.toLowerCase(),
          quote.isActive ? 'active' : 'draft',
        ].filter((tag): tag is string => Boolean(tag)),
      },
      create: {
        entityType: 'COZY_QUOTE',
        entityId: quote.id,
        title: this.truncate(quote.content, 84),
        content: [
          quote.content,
          quote.author,
          quote.mood,
          quote.isActive ? 'active' : 'draft',
        ]
          .filter(Boolean)
          .join(' '),
        tags: [
          'quote',
          'cozy',
          quote.mood?.toLowerCase(),
          quote.isActive ? 'active' : 'draft',
        ].filter((tag): tag is string => Boolean(tag)),
      },
    });
  }

  private truncate(value: string, length: number) {
    return value.length <= length ? value : `${value.slice(0, length - 1)}...`;
  }

  private async ensureExists(id: string) {
    const quote = await this.prisma.cozyQuote.findUnique({
      where: { id },
      select: { id: true },
    });

    if (!quote) {
      throw AppException.notFound(
        ErrorCode.CATALOG_COZY_QUOTE_NOT_FOUND,
        'Cozy quote not found',
      );
    }
  }
}
