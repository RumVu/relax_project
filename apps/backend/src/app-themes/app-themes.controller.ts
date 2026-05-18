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
import { AppThemesService } from './app-themes.service';
import { CreateAppThemeDto } from './dto/create-app-theme.dto';
import { UpdateAppThemeDto } from './dto/update-app-theme.dto';

@ApiTags('App Themes')
@Controller('app-themes')
export class AppThemesController {
  constructor(private readonly appThemesService: AppThemesService) {}

  @ApiOperation({ summary: 'List app themes' })
  @ApiOkResponse({ description: 'Theme catalog list.' })
  @Get()
  findAll() {
    return this.appThemesService.findAll();
  }

  @ApiOperation({ summary: 'Get the default app theme' })
  @ApiOkResponse({ description: 'Default active theme.' })
  @Get('default')
  findDefault() {
    return this.appThemesService.findDefault();
  }

  @ApiOperation({ summary: 'Create an app theme' })
  @ApiCreatedResponse({ description: 'Created app theme.' })
  @AdminOnly()
  @Post()
  create(@Body() dto: CreateAppThemeDto) {
    return this.appThemesService.create(dto);
  }

  @ApiOperation({ summary: 'Update an app theme' })
  @ApiOkResponse({ description: 'Updated app theme.' })
  @AdminOnly()
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateAppThemeDto) {
    return this.appThemesService.update(id, dto);
  }

  @ApiOperation({ summary: 'Delete an app theme' })
  @ApiOkResponse({ description: 'Deleted app theme.' })
  @AdminOnly()
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.appThemesService.remove(id);
  }
}
