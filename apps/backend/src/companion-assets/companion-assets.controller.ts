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
import { CompanionAssetsService } from './companion-assets.service';
import { CreateCompanionAssetDto } from './dto/create-companion-asset.dto';
import { UpdateCompanionAssetDto } from './dto/update-companion-asset.dto';

@ApiTags('Companion Assets')
@Controller('companion-assets')
export class CompanionAssetsController {
  constructor(
    private readonly companionAssetsService: CompanionAssetsService,
  ) {}

  @ApiOperation({ summary: 'List companion assets' })
  @ApiOkResponse({ description: 'Companion asset catalog list.' })
  @Get()
  findAll() {
    return this.companionAssetsService.findAll();
  }

  @ApiOperation({ summary: 'Get the default companion asset' })
  @ApiOkResponse({ description: 'Default active companion asset.' })
  @Get('default')
  findDefault() {
    return this.companionAssetsService.findDefault();
  }

  @ApiOperation({ summary: 'Create a companion asset' })
  @ApiCreatedResponse({ description: 'Created companion asset.' })
  @AdminOnly()
  @Post()
  create(@Body() dto: CreateCompanionAssetDto) {
    return this.companionAssetsService.create(dto);
  }

  @ApiOperation({ summary: 'Update a companion asset' })
  @ApiOkResponse({ description: 'Updated companion asset.' })
  @AdminOnly()
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateCompanionAssetDto) {
    return this.companionAssetsService.update(id, dto);
  }

  @ApiOperation({ summary: 'Delete a companion asset' })
  @ApiOkResponse({ description: 'Deleted companion asset.' })
  @AdminOnly()
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.companionAssetsService.remove(id);
  }
}
