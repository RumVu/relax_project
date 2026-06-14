import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiCreatedResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import type { AuthUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { HealthIntegrationService } from './health-integration.service';
import { SyncHealthDto } from './dto/sync-health.dto';
import { LinkIntegrationDto } from './dto/link-integration.dto';

@ApiTags('Health Integration')
@ApiBearerAuth('access-token')
@Controller('health-integration')
export class HealthIntegrationController {
  constructor(private readonly service: HealthIntegrationService) {}

  @ApiOperation({ summary: 'Sync health data from mobile device' })
  @ApiCreatedResponse({ description: 'Health data synced.' })
  @UseGuards(JwtAuthGuard)
  @Post('sync')
  syncHealthData(@CurrentUser() user: AuthUser, @Body() dto: SyncHealthDto) {
    return this.service.syncHealthData(user.id, dto);
  }

  @ApiOperation({ summary: 'Get health-mood correlation insights' })
  @ApiOkResponse({ description: 'Health-mood correlation data.' })
  @UseGuards(JwtAuthGuard)
  @Get('correlation')
  getHealthCorrelation(@CurrentUser() user: AuthUser) {
    return this.service.getHealthCorrelation(user.id);
  }

  @ApiOperation({
    summary: 'Get integration status (Apple Health, Google Fit)',
  })
  @ApiOkResponse({ description: 'Integration status map.' })
  @UseGuards(JwtAuthGuard)
  @Get('status')
  getIntegrationStatus(@CurrentUser() user: AuthUser) {
    return this.service.getIntegrationStatus(user.id);
  }

  @ApiOperation({ summary: 'Link an integration (Apple Health / Google Fit)' })
  @ApiCreatedResponse({ description: 'Integration linked.' })
  @UseGuards(JwtAuthGuard)
  @Post('link')
  linkIntegration(
    @CurrentUser() user: AuthUser,
    @Body() dto: LinkIntegrationDto,
  ) {
    return this.service.linkIntegration(user.id, dto.type);
  }

  @ApiOperation({ summary: 'Unlink an integration' })
  @ApiOkResponse({ description: 'Integration unlinked.' })
  @UseGuards(JwtAuthGuard)
  @Delete('link/:type')
  unlinkIntegration(
    @CurrentUser() user: AuthUser,
    @Param('type') type: string,
  ) {
    return this.service.unlinkIntegration(user.id, type);
  }
}
