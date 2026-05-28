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
import { AppThemesService } from './app-themes.service';
import {
  AppThemePageDto,
  AppThemeResponseDto,
} from './dto/app-theme-response.dto';
import { CreateAppThemeDto } from './dto/create-app-theme.dto';
import { UpdateAppThemeDto } from './dto/update-app-theme.dto';

@ApiTags('App Themes')
@Controller('app-themes')
export class AppThemesController {
  constructor(private readonly appThemesService: AppThemesService) {}

  @ApiOperation({ summary: 'List app themes' })
  @ApiOkResponse({ type: AppThemePageDto, description: 'Theme catalog list.' })
  @Get()
  findAll(@Query() query: CatalogQueryDto) {
    return this.appThemesService.findAll(query);
  }

  @ApiOperation({ summary: 'Get the default app theme' })
  @ApiOkResponse({
    type: AppThemeResponseDto,
    description: 'Default active theme.',
  })
  @Get('default')
  findDefault() {
    return this.appThemesService.findDefault();
  }

  @ApiOperation({ summary: 'Create an app theme' })
  @ApiCreatedResponse({
    type: AppThemeResponseDto,
    description: 'Created app theme.',
  })
  @AdminOnly()
  @Post()
  create(@Body() dto: CreateAppThemeDto) {
    return this.appThemesService.create(dto);
  }

  @ApiOperation({ summary: 'Update an app theme' })
  @ApiOkResponse({
    type: AppThemeResponseDto,
    description: 'Updated app theme.',
  })
  @AdminOnly()
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateAppThemeDto) {
    return this.appThemesService.update(id, dto);
  }

  @ApiOperation({ summary: 'Delete an app theme' })
  @ApiOkResponse({
    type: AppThemeResponseDto,
    description: 'Deleted app theme.',
  })
  @AdminOnly()
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.appThemesService.remove(id);
  }
}
