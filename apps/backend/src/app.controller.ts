import { Controller, Get, Query, Res, UseGuards } from '@nestjs/common';
import type { Response } from 'express';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
import { UserRole } from '@prisma/client';
import { AppService } from './app.service';
import { JwtAuthGuard } from './auth/guards/jwt-auth.guard';
import { RolesGuard } from './auth/guards/roles.guard';
import { Roles } from './auth/decorators/roles.decorator';

@ApiTags('Health')
@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}

  @ApiOperation({ summary: 'Get API index and exposed module map' })
  @ApiOkResponse({
    description:
      'Returns the backend entrypoint, docs links, health links, and exposed API groups.',
  })
  @Get()
  getApiIndex() {
    return this.appService.getApiIndex();
  }

  @ApiOperation({ summary: 'Get API index alias' })
  @ApiOkResponse({
    description:
      'Alias of GET / for clients that prefer an explicit API discovery path.',
  })
  @Get('api')
  getApiIndexAlias() {
    return this.appService.getApiIndex();
  }

  @ApiOperation({ summary: 'Get shallow API liveness status' })
  @ApiQuery({
    name: 'deep',
    required: false,
    description:
      'Set true to include database/storage readiness without changing the /ready contract.',
  })
  @ApiOkResponse({
    description:
      'Returns process liveness. With deep=true it returns the same readiness payload as GET /ready.',
  })
  @Get('health')
  getHealth(@Query('deep') deep?: string) {
    if (deep === 'true' || deep === '1') {
      return this.appService.getReady();
    }

    return this.appService.getHealth();
  }

  @ApiOperation({ summary: 'Get deep API readiness status' })
  @ApiOkResponse({
    description: 'Returns database and storage configuration readiness checks.',
  })
  @Get('ready')
  async getReady(@Res({ passthrough: true }) res: Response) {
    const result = await this.appService.getReady();
    if (result.status !== 'ok') {
      res.status(503);
    }
    return result;
  }

  @ApiOperation({ summary: 'Get full ops status for admin dashboard' })
  @ApiOkResponse({
    description:
      'Returns DB, Redis, Queue, provider, and user stats for ops dashboard.',
  })
  @ApiBearerAuth('access-token')
  @UseGuards(JwtAuthGuard, RolesGuard)
  @Roles(UserRole.ADMIN)
  @Get('ops')
  getOps() {
    return this.appService.getOpsStatus();
  }
}
