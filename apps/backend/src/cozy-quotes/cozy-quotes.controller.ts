import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  ParseEnumPipe,
  Patch,
  Post,
} from '@nestjs/common';
import {
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { MoodType } from '@prisma/client';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import { CozyQuotesService } from './cozy-quotes.service';
import { CreateCozyQuoteDto } from './dto/create-cozy-quote.dto';
import { UpdateCozyQuoteDto } from './dto/update-cozy-quote.dto';

@ApiTags('Cozy Quotes')
@Controller('cozy-quotes')
export class CozyQuotesController {
  constructor(private readonly cozyQuotesService: CozyQuotesService) {}

  @ApiOperation({ summary: 'List cozy quotes' })
  @ApiOkResponse({ description: 'Cozy quote catalog list.' })
  @Get()
  findAll() {
    return this.cozyQuotesService.findAll();
  }

  @ApiOperation({ summary: 'Get a random active cozy quote' })
  @ApiOkResponse({ description: 'Random cozy quote.' })
  @Get('random')
  findRandom() {
    return this.cozyQuotesService.findRandom();
  }

  @ApiOperation({ summary: 'List cozy quotes by mood' })
  @ApiOkResponse({ description: 'Cozy quotes matching the mood.' })
  @Get('mood/:mood')
  findByMood(@Param('mood', new ParseEnumPipe(MoodType)) mood: MoodType) {
    return this.cozyQuotesService.findByMood(mood);
  }

  @ApiOperation({ summary: 'Create a cozy quote' })
  @ApiCreatedResponse({ description: 'Created cozy quote.' })
  @AdminOnly()
  @Post()
  create(@Body() dto: CreateCozyQuoteDto) {
    return this.cozyQuotesService.create(dto);
  }

  @ApiOperation({ summary: 'Update a cozy quote' })
  @ApiOkResponse({ description: 'Updated cozy quote.' })
  @AdminOnly()
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateCozyQuoteDto) {
    return this.cozyQuotesService.update(id, dto);
  }

  @ApiOperation({ summary: 'Delete a cozy quote' })
  @ApiOkResponse({ description: 'Deleted cozy quote.' })
  @AdminOnly()
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.cozyQuotesService.remove(id);
  }
}
