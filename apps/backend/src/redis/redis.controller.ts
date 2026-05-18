import { Controller, Get, Query } from '@nestjs/common';
import {
  ApiOkResponse,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
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
  @Get('health')
  health(@Query('deep') deep?: string) {
    if (deep === 'true') {
      return this.redisService.ping();
    }

    return this.redisService.getStatus();
  }
}
