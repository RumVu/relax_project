import { Controller, Get, Query } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import { RedisService } from './redis.service';

@ApiTags('Redis')
@Controller('redis')
export class RedisController {
  constructor(private readonly redisService: RedisService) {}

  @ApiOperation({
    summary: 'Get Redis configuration and optional deep connectivity health',
  })
  @ApiQuery({
    name: 'deep',
    required: false,
    example: true,
    description: 'Set true to run a real Redis PING.',
  })
  @ApiOkResponse({ description: 'Redis health payload.' })
  @ApiBearerAuth('access-token')
  @AdminOnly()
  @Get('health')
  health(@Query('deep') deep?: string) {
    if (deep === 'true') {
      return this.redisService.ping();
    }

    return this.redisService.getStatus();
  }
}
