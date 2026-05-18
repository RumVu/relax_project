import { Body, Controller, Get, Patch, Post, UseGuards } from '@nestjs/common';
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
import { CreateCompanionInteractionDto } from './dto/create-companion-interaction.dto';
import { SwitchCompanionPersonalizationDto } from './dto/switch-companion-personalization.dto';
import { UpsertUserCompanionDto } from './dto/upsert-user-companion.dto';
import { UserCompanionsService } from './user-companions.service';

@ApiTags('User Companions')
@ApiBearerAuth('access-token')
@Controller('user-companions')
export class UserCompanionsController {
  constructor(private readonly userCompanionsService: UserCompanionsService) {}

  @ApiOperation({ summary: 'Get current user companion' })
  @ApiOkResponse({ description: 'Current user companion.' })
  @UseGuards(JwtAuthGuard)
  @Get('me')
  getMine(@CurrentUser() user: AuthUser) {
    return this.userCompanionsService.getMine(user.id);
  }

  @ApiOperation({ summary: 'Upsert current user companion' })
  @ApiOkResponse({ description: 'Updated current user companion.' })
  @UseGuards(JwtAuthGuard)
  @Patch('me')
  upsertMine(
    @CurrentUser() user: AuthUser,
    @Body() dto: UpsertUserCompanionDto,
  ) {
    return this.userCompanionsService.upsertMine(user.id, dto);
  }

  @ApiOperation({ summary: 'Get companion personalization options' })
  @ApiOkResponse({
    description:
      'Available default, zodiac, chinese zodiac, and custom companion options.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me/personalization-options')
  getPersonalizationOptions(@CurrentUser() user: AuthUser) {
    return this.userCompanionsService.getPersonalizationOptions(user.id);
  }

  @ApiOperation({
    summary:
      'Switch companion personalization mode while preserving or resetting progress',
  })
  @ApiOkResponse({
    description:
      'Updated companion plus transition rule for zodiac/chinese zodiac/custom switching.',
  })
  @UseGuards(JwtAuthGuard)
  @Patch('me/personalization-mode')
  switchPersonalization(
    @CurrentUser() user: AuthUser,
    @Body() dto: SwitchCompanionPersonalizationDto,
  ) {
    return this.userCompanionsService.switchPersonalization(user.id, dto);
  }

  @ApiOperation({ summary: 'Create companion interaction' })
  @ApiCreatedResponse({
    description: 'Created interaction and updated companion.',
  })
  @UseGuards(JwtAuthGuard)
  @Post('me/interactions')
  interact(
    @CurrentUser() user: AuthUser,
    @Body() dto: CreateCompanionInteractionDto,
  ) {
    return this.userCompanionsService.interact(user.id, dto);
  }

  @ApiOperation({ summary: 'Get current user companion stats' })
  @ApiOkResponse({ description: 'Companion stats.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/stats')
  getStats(@CurrentUser() user: AuthUser) {
    return this.userCompanionsService.getStats(user.id);
  }
}
