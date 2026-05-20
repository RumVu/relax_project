import { Controller, Get, Query } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import { QueuesService } from './queues.service';

@ApiTags('Queues')
@Controller('queues')
export class QueuesController {
  constructor(private readonly queuesService: QueuesService) {}

  @ApiOperation({
    summary: 'Get Redis-backed queue health and registered queue names',
  })
  @ApiQuery({
    name: 'deep',
    required: false,
    example: true,
    description: 'Set true to run a real Redis PING for queue infrastructure.',
  })
  @ApiOkResponse({
    description: 'Queue configuration and optional Redis PING.',
  })
  @ApiBearerAuth('access-token')
  @AdminOnly()
  @Get('health')
  health(@Query('deep') deep?: string) {
    return this.queuesService.health(deep === 'true');
  }
}
