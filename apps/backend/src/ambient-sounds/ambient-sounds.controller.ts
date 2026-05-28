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
import { AmbientSoundsService } from './ambient-sounds.service';
import {
  AmbientSoundPageDto,
  AmbientSoundResponseDto,
} from './dto/ambient-sound-response.dto';
import { CreateAmbientSoundDto } from './dto/create-ambient-sound.dto';
import { UpdateAmbientSoundDto } from './dto/update-ambient-sound.dto';

@ApiTags('Ambient Sounds')
@Controller('ambient-sounds')
export class AmbientSoundsController {
  constructor(private readonly ambientSoundsService: AmbientSoundsService) {}

  @ApiOperation({ summary: 'List ambient sounds' })
  @ApiOkResponse({
    type: AmbientSoundPageDto,
    description: 'Ambient sound catalog list.',
  })
  @Get()
  findAll(@Query() query: CatalogQueryDto) {
    return this.ambientSoundsService.findAll(query);
  }

  @ApiOperation({ summary: 'List ambient sounds by category' })
  @ApiOkResponse({
    type: AmbientSoundResponseDto,
    isArray: true,
    description: 'Ambient sounds in the requested category.',
  })
  @Get('category/:category')
  findByCategory(@Param('category') category: string) {
    return this.ambientSoundsService.findByCategory(category);
  }

  @ApiOperation({ summary: 'Create an ambient sound' })
  @ApiCreatedResponse({
    type: AmbientSoundResponseDto,
    description: 'Created ambient sound.',
  })
  @AdminOnly()
  @Post()
  create(@Body() dto: CreateAmbientSoundDto) {
    return this.ambientSoundsService.create(dto);
  }

  @ApiOperation({ summary: 'Update an ambient sound' })
  @ApiOkResponse({
    type: AmbientSoundResponseDto,
    description: 'Updated ambient sound.',
  })
  @AdminOnly()
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateAmbientSoundDto) {
    return this.ambientSoundsService.update(id, dto);
  }

  @ApiOperation({ summary: 'Delete an ambient sound' })
  @ApiOkResponse({
    type: AmbientSoundResponseDto,
    description: 'Deleted ambient sound.',
  })
  @AdminOnly()
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.ambientSoundsService.remove(id);
  }
}
