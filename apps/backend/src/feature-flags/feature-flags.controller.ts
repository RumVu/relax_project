import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { Roles } from '../auth/decorators/roles.decorator';
import { FeatureFlagsService } from './feature-flags.service';
import { UpsertFeatureFlagDto } from './dto/upsert-feature-flag.dto';

@ApiTags('Feature Flags')
@Controller('feature-flags')
export class FeatureFlagsController {
  constructor(private readonly service: FeatureFlagsService) {}

  @Get()
  findAll() {
    return this.service.findAll();
  }

  @Get(':key')
  findByKey(@Param('key') key: string) {
    return this.service.findByKey(key);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @Post()
  upsert(@Body() dto: UpsertFeatureFlagDto) {
    return this.service.upsert(dto);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @Patch(':key/toggle')
  toggle(@Param('key') key: string) {
    return this.service.toggle(key);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @Delete(':key')
  delete(@Param('key') key: string) {
    return this.service.delete(key);
  }

  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles('ADMIN')
  @Post('seed')
  seed() {
    return this.service.seedDefaults();
  }
}
