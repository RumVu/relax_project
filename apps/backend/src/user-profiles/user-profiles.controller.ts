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
import { UpsertUserProfileDto } from './dto/upsert-user-profile.dto';
import { UserProfilesService } from './user-profiles.service';

@ApiTags('User Profiles')
@Controller('user-profiles')
export class UserProfilesController {
  constructor(private readonly userProfilesService: UserProfilesService) {}

  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Get a user profile by user id (admin)' })
  @ApiOkResponse({ description: 'User profile payload.' })
  @ApiForbiddenResponse({ description: 'Requires ADMIN role.' })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Get(':userId')
  findByUserId(@Param('userId') userId: string) {
    return this.userProfilesService.findByUserId(userId);
  }

  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Upsert a user profile by user id (admin)' })
  @ApiOkResponse({ description: 'Upserted user profile payload.' })
  @ApiForbiddenResponse({ description: 'Requires ADMIN role.' })
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Patch(':userId')
  upsert(@Param('userId') userId: string, @Body() dto: UpsertUserProfileDto) {
    return this.userProfilesService.upsert(userId, dto);
  }

  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Get the current user profile' })
  @ApiOkResponse({ description: 'Current user profile payload.' })
  @UseGuards(JwtAuthGuard)
  @Get('me/profile')
  findMine(@CurrentUser() user: AuthUser) {
    return this.userProfilesService.findByUserId(user.id);
  }

  @ApiBearerAuth('access-token')
  @ApiOperation({ summary: 'Upsert the current user profile' })
  @ApiOkResponse({ description: 'Upserted current user profile payload.' })
  @UseGuards(JwtAuthGuard)
  @Patch('me/profile')
  upsertMine(@CurrentUser() user: AuthUser, @Body() dto: UpsertUserProfileDto) {
    return this.userProfilesService.upsert(user.id, dto);
  }
}
