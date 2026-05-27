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
import { CreateOnboardingSlideDto } from './dto/create-onboarding-slide.dto';
import { UpdateOnboardingSlideDto } from './dto/update-onboarding-slide.dto';
import { OnboardingSlidesService } from './onboarding-slides.service';

@ApiTags('Onboarding Slides')
@Controller('onboarding-slides')
export class OnboardingSlidesController {
  constructor(
    private readonly onboardingSlidesService: OnboardingSlidesService,
  ) {}

  @ApiOperation({ summary: 'List onboarding slides' })
  @ApiOkResponse({ description: 'Active onboarding slide list.' })
  @Get()
  findAll(@Query() query: CatalogQueryDto) {
    return this.onboardingSlidesService.findAll(query);
  }

  @ApiOperation({ summary: 'Create an onboarding slide' })
  @ApiCreatedResponse({ description: 'Created onboarding slide.' })
  @AdminOnly()
  @Post()
  create(@Body() dto: CreateOnboardingSlideDto) {
    return this.onboardingSlidesService.create(dto);
  }

  @ApiOperation({ summary: 'Update an onboarding slide' })
  @ApiOkResponse({ description: 'Updated onboarding slide.' })
  @AdminOnly()
  @Patch(':id')
  update(@Param('id') id: string, @Body() dto: UpdateOnboardingSlideDto) {
    return this.onboardingSlidesService.update(id, dto);
  }

  @ApiOperation({ summary: 'Delete an onboarding slide' })
  @ApiOkResponse({ description: 'Deleted onboarding slide.' })
  @AdminOnly()
  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.onboardingSlidesService.remove(id);
  }
}
