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
import { AmbientSoundsService } from './ambient-sounds.service';
import { CreateAmbientSoundDto } from './dto/create-ambient-sound.dto';
import { UpdateAmbientSoundDto } from './dto/update-ambient-sound.dto';

@ApiTags('Ambient Sounds')
@Controller('ambient-sounds')
export class AmbientSoundsController {
  constructor(private readonly ambientSoundsService: AmbientSoundsService) {}

  @ApiOperation({ summary: 'List ambient sounds' })
  @ApiOkResponse({ description: 'Ambient sound catalog list.' })
  @Get()
  findAll() {
    return this.ambientSoundsService.findAll();
  }

  @ApiOperation({ summary: 'List ambient sounds by category' })
  @ApiOkResponse({ description: 'Ambient sounds in the requested category.' })
  @Get('category/:category')
  findByCategory(@Param('category') category: string) {
    return this.ambientSoundsService.findByCategory(category);
  }

  @ApiOperation({ summary: 'Create an ambient sound' })
  @ApiCreatedResponse({ description: 'Created ambient sound.' })
  @AdminOnly()
  @Post()
  create(@Body() dto: CreateAmbientSoundDto) {
    return this.ambientSoundsService.create(dto);
  }

  @ApiOperation({ summary: 'Update an ambient sound' })
  @ApiOkResponse({ description: 'Updated ambient sound.' })
  @AdminOnly()
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateAmbientSoundDto) {
    return this.ambientSoundsService.update(id, dto);
  }

  @ApiOperation({ summary: 'Delete an ambient sound' })
  @ApiOkResponse({ description: 'Deleted ambient sound.' })
  @AdminOnly()
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.ambientSoundsService.remove(id);
  }
}
