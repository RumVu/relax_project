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

  create(dto: CreateCozyQuoteDto) {
    return this.prisma.cozyQuote.create({ data: dto });
  }

  async update(id: string, dto: UpdateCozyQuoteDto) {
    await this.ensureExists(id);
    return this.prisma.cozyQuote.update({ where: { id }, data: dto });
  }

  async remove(id: string) {
    await this.ensureExists(id);
    return this.prisma.cozyQuote.delete({ where: { id } });
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
