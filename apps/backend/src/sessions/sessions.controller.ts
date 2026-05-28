import { Controller, Delete, Get, Param, UseGuards } from '@nestjs/common';
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
import { SessionResponseDto } from './dto/session-response.dto';
import { SessionsService } from './sessions.service';

@ApiTags('Sessions')
@ApiBearerAuth('access-token')
@Controller('sessions')
export class SessionsController {
  constructor(private readonly sessionsService: SessionsService) {}

  @ApiOperation({ summary: 'List all sessions (admin)' })
  @ApiOkResponse({
    type: SessionResponseDto,
    isArray: true,
    description: 'All sessions with a user summary.',
  })
  @ApiForbiddenResponse({ description: 'Requires ADMIN role.' })
  @Get()
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  findAll() {
    return this.sessionsService.findAll();
  }

  @ApiOperation({ summary: 'List sessions for one user (admin)' })
  @ApiOkResponse({
    type: SessionResponseDto,
    isArray: true,
    description: 'Sessions for the requested user.',
  })
  @ApiForbiddenResponse({ description: 'Requires ADMIN role.' })
  @Get('user/:userId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  findByUserId(@Param('userId') userId: string) {
    return this.sessionsService.findByUserId(userId);
  }

  @ApiOperation({ summary: 'List sessions for the current user' })
  @ApiOkResponse({
    type: SessionResponseDto,
    isArray: true,
    description: 'Current user sessions.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me')
  findMine(@CurrentUser() user: AuthUser) {
    return this.sessionsService.findByUserId(user.id);
  }

  @ApiOperation({ summary: 'Revoke one session (admin)' })
  @ApiOkResponse({
    type: SessionResponseDto,
    description: 'Deleted session payload.',
  })
  @ApiForbiddenResponse({ description: 'Requires ADMIN role.' })
  @Delete(':id')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  revoke(@Param('id') id: string) {
    return this.sessionsService.revoke(id);
  }

  @ApiOperation({ summary: 'Revoke all sessions for one user (admin)' })
  @ApiOkResponse({ description: 'Count of revoked sessions.' })
  @ApiForbiddenResponse({ description: 'Requires ADMIN role.' })
  @Delete('user/:userId')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  revokeUserSessions(@Param('userId') userId: string) {
    return this.sessionsService.revokeUserSessions(userId);
  }
}
