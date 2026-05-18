import { applyDecorators, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiForbiddenResponse } from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { JwtAuthGuard } from '../guards/jwt-auth.guard';
import { RolesGuard } from '../guards/roles.guard';
import { Roles } from './roles.decorator';

export function AdminOnly() {
  return applyDecorators(
    ApiBearerAuth('access-token'),
    ApiForbiddenResponse({ description: 'Requires ADMIN role.' }),
    UseGuards(JwtAuthGuard, RolesGuard),
    Roles(UserRole.ADMIN),
  );
}
