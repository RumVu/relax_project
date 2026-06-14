import {
  Body,
  Controller,
  Delete,
  Get,
  Patch,
  Query,
  UseGuards,
} from '@nestjs/common';
import { PrivacyService } from './privacy.service';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import type { AuthUser } from '../auth/auth.types';
import { UpdatePrivacySettingsDto } from './dto/update-privacy-settings.dto';

@Controller('privacy')
@UseGuards(JwtAuthGuard)
export class PrivacyController {
  constructor(private readonly privacyService: PrivacyService) {}

  @Get('summary')
  async getDataSummary(@CurrentUser() user: AuthUser) {
    return this.privacyService.getDataSummary(user.id);
  }

  @Get('export')
  async exportData(
    @CurrentUser() user: AuthUser,
    @Query('format') format?: 'json' | 'csv',
  ) {
    return this.privacyService.exportData(user.id, format ?? 'json');
  }

  @Delete('journals')
  async deleteJournals(@CurrentUser() user: AuthUser) {
    return this.privacyService.deleteJournalsOnly(user.id);
  }

  @Delete('mood-history')
  async deleteMoodHistory(@CurrentUser() user: AuthUser) {
    return this.privacyService.deleteMoodHistory(user.id);
  }

  @Delete('sessions')
  async deleteSessionHistory(@CurrentUser() user: AuthUser) {
    return this.privacyService.deleteSessionHistory(user.id);
  }

  @Get('settings')
  async getPrivacySettings(@CurrentUser() user: AuthUser) {
    return this.privacyService.getPrivacySettings(user.id);
  }

  @Patch('settings')
  async updatePrivacySettings(
    @CurrentUser() user: AuthUser,
    @Body() dto: UpdatePrivacySettingsDto,
  ) {
    return this.privacyService.updatePrivacySettings(user.id, dto);
  }
}
