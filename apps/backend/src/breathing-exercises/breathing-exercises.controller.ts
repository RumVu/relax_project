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
import { BreathingExercisesService } from './breathing-exercises.service';
import { CreateBreathingExerciseDto } from './dto/create-breathing-exercise.dto';
import { UpdateBreathingExerciseDto } from './dto/update-breathing-exercise.dto';

@ApiTags('Breathing Exercises')
@Controller('breathing-exercises')
export class BreathingExercisesController {
  constructor(
    private readonly breathingExercisesService: BreathingExercisesService,
  ) {}

  @ApiOperation({ summary: 'List breathing exercises' })
  @ApiOkResponse({ description: 'Breathing exercise catalog list.' })
  @Get()
  findAll(@Query() query: CatalogQueryDto) {
    return this.breathingExercisesService.findAll(query);
  }

  @ApiOperation({ summary: 'Create a breathing exercise' })
  @ApiCreatedResponse({ description: 'Created breathing exercise.' })
  @AdminOnly()
  @Post()
  create(@Body() dto: CreateBreathingExerciseDto) {
    return this.breathingExercisesService.create(dto);
  }

  @ApiOperation({ summary: 'Update a breathing exercise' })
  @ApiOkResponse({ description: 'Updated breathing exercise.' })
  @AdminOnly()
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateBreathingExerciseDto) {
    return this.breathingExercisesService.update(id, dto);
  }

  @ApiOperation({ summary: 'Delete a breathing exercise' })
  @ApiOkResponse({ description: 'Deleted breathing exercise.' })
  @AdminOnly()
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.breathingExercisesService.remove(id);
  }
}
