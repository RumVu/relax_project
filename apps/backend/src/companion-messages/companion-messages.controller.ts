import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
} from '@nestjs/common';
import {
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import { CompanionMessagesService } from './companion-messages.service';
import { CreateCompanionMessageDto } from './dto/create-companion-message.dto';
import { UpdateCompanionMessageDto } from './dto/update-companion-message.dto';

@ApiTags('Companion Messages')
@Controller('companion-messages')
export class CompanionMessagesController {
  constructor(
    private readonly companionMessagesService: CompanionMessagesService,
  ) {}

  @ApiOperation({ summary: 'List companion messages' })
  @ApiOkResponse({ description: 'Companion message catalog list.' })
  @Get()
  findAll() {
    return this.companionMessagesService.findAll();
  }

  @ApiOperation({ summary: 'Get a random active companion message' })
  @ApiOkResponse({ description: 'Random companion message.' })
  @Get('random')
  findRandom() {
    return this.companionMessagesService.findRandom();
  }

  @ApiOperation({ summary: 'Create a companion message' })
  @ApiCreatedResponse({ description: 'Created companion message.' })
  @AdminOnly()
  @Post()
  create(@Body() dto: CreateCompanionMessageDto) {
    return this.companionMessagesService.create(dto);
  }

  @ApiOperation({ summary: 'Update a companion message' })
  @ApiOkResponse({ description: 'Updated companion message.' })
  @AdminOnly()
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateCompanionMessageDto) {
    return this.companionMessagesService.update(id, dto);
  }

  @ApiOperation({ summary: 'Delete a companion message' })
  @ApiOkResponse({ description: 'Deleted companion message.' })
  @AdminOnly()
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.companionMessagesService.remove(id);
  }
}
