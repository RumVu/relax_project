import { Body, Controller, Get, Param, Patch, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiForbiddenResponse,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import type { AuthUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { Roles } from '../auth/decorators/roles.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import { RolesGuard } from '../auth/guards/roles.guard';
import { UpsertUserPreferenceDto } from './dto/upsert-user-preference.dto';
import { UserPreferenceResponseDto } from './dto/user-preference-response.dto';
import { UserPreferencesService } from './user-preferences.service';

@ApiTags('User Preferences')
@Controller('user-preferences')
export class UserPreferencesController {
  constructor(
    private readonly userPreferencesService: UserPreferencesService,
  ) {}

  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Get user preferences by user id (admin)' })
  @ApiOkResponse({ type: UserPreferenceResponseDto, description: 'User preferences payload.' })
  @ApiForbiddenResponse({ description: 'Requires ADMIN role.' })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Get(':userId')
  findByUserId(@Param('userId') userId: string) {
    return this.userPreferencesService.findByUserId(userId);
  }

  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Upsert user preferences by user id (admin)' })
  @ApiOkResponse({ type: UserPreferenceResponseDto, description: 'Upserted user preferences payload.' })
  @ApiForbiddenResponse({ description: 'Requires ADMIN role.' })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Patch(':userId')
  upsert(
    @Param('userId') userId: string,
    @Body() dto: UpsertUserPreferenceDto,
  ) {
    return this.userPreferencesService.upsert(userId, dto);
  }

  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Get the current user preferences' })
  @ApiOkResponse({ type: UserPreferenceResponseDto, description: 'Current user preferences payload.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/preferences')
  findMine(@CurrentUser() user: AuthUser) {
    return this.userPreferencesService.findByUserId(user.id);
  }

  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Upsert the current user preferences' })
  @ApiOkResponse({ type: UserPreferenceResponseDto, description: 'Upserted current user preferences payload.' })
  @UseGuards(JwtAuthGuard)
  @Patch('me/preferences')
  upsertMine(
    @CurrentUser() user: AuthUser,
    @Body() dto: UpsertUserPreferenceDto,
  ) {
    return this.userPreferencesService.upsert(user.id, dto);
  }
}
