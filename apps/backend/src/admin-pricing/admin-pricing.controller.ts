import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
} from '@nestjs/common';
import { ApiOperation, ApiTags } from '@nestjs/swagger';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import { AdminPricingService } from './admin-pricing.service';
import { CreateTierDto, UpdateTierDto } from './dto/upsert-tier.dto';

@ApiTags('Admin · Pricing')
@AdminOnly()
@Controller('admin/billing/tiers')
export class AdminPricingController {
  constructor(private readonly service: AdminPricingService) {}

  @Get()
  @ApiOperation({
    summary: 'List every subscription tier (active + inactive).',
  })
  list() {
    return this.service.list();
  }

  @Get(':id')
  @ApiOperation({ summary: 'Fetch one tier by id.' })
  findOne(@Param('id') id: string) {
    return this.service.findOne(id);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new tier.' })
  create(@Body() dto: CreateTierDto) {
    return this.service.create(dto);
  }

  @Patch(':id')
  @ApiOperation({
    summary:
      'Update price, sale, title, display order, or activation flag of a tier.',
  })
  update(@Param('id') id: string, @Body() dto: UpdateTierDto) {
    return this.service.update(id, dto);
  }

  @Patch(':id/clear-sale')
  @ApiOperation({
    summary: 'Drop the active sale window without touching the regular price.',
  })
  clearSale(@Param('id') id: string) {
    return this.service.clearSale(id);
  }

  @Delete(':id')
  @ApiOperation({
    summary:
      'Soft-deactivate the tier (sets isActive=false). Hard-delete would orphan past payments.',
  })
  deactivate(@Param('id') id: string) {
    return this.service.deactivate(id);
  }
}
