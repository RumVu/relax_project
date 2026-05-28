import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  Query,
} from '@nestjs/common';
import {
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import { CatalogQueryDto } from '../common/dto/catalog-query.dto';
import { CompanionMessagesService } from './companion-messages.service';
import {
  CompanionMessagePageDto,
  CompanionMessageResponseDto,
} from './dto/companion-message-response.dto';
import { CreateCompanionMessageDto } from './dto/create-companion-message.dto';
import { UpdateCompanionMessageDto } from './dto/update-companion-message.dto';

@ApiTags('Companion Messages')
@Controller('companion-messages')
export class CompanionMessagesController {
  constructor(
    private readonly companionMessagesService: CompanionMessagesService,
  ) {}

  @ApiOperation({ summary: 'List companion messages' })
  @ApiOkResponse({
    type: CompanionMessagePageDto,
    description: 'Companion message catalog list.',
  })
  @Get()
  findAll(@Query() query: CatalogQueryDto) {
    return this.companionMessagesService.findAll(query);
  }

  @ApiOperation({ summary: 'Get a random active companion message' })
  @ApiOkResponse({
    type: CompanionMessageResponseDto,
    description: 'Random companion message.',
  })
  @Get('random')
  findRandom() {
    return this.companionMessagesService.findRandom();
  }

  @ApiOperation({ summary: 'Create a companion message' })
  @ApiCreatedResponse({
    type: CompanionMessageResponseDto,
    description: 'Created companion message.',
  })
  @AdminOnly()
  @Post()
  create(@Body() dto: CreateCompanionMessageDto) {
    return this.companionMessagesService.create(dto);
  }

  @ApiOperation({ summary: 'Update a companion message' })
  @ApiOkResponse({
    type: CompanionMessageResponseDto,
    description: 'Updated companion message.',
  })
  @AdminOnly()
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateCompanionMessageDto) {
    return this.companionMessagesService.update(id, dto);
  }

  @ApiOperation({ summary: 'Delete a companion message' })
  @ApiOkResponse({
    type: CompanionMessageResponseDto,
    description: 'Deleted companion message.',
  })
  @AdminOnly()
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.companionMessagesService.remove(id);
  }
}
