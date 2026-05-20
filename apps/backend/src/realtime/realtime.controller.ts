import { Controller, Get } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { AdminOnly } from '../auth/decorators/admin-only.decorator';
import { RealtimeService } from './realtime.service';

@ApiTags('Realtime')
@Controller('realtime')
export class RealtimeController {
  constructor(private readonly realtimeService: RealtimeService) {}

  @ApiOperation({
    summary: 'Get Socket.IO realtime status and Redis adapter mode',
  })
  @ApiOkResponse({
    description:
      'Realtime status, namespace, Redis adapter mode, and connected client count.',
  })
  @ApiBearerAuth('access-token')
  @AdminOnly()
  @Get('health')
  health() {
    return this.realtimeService.getStatus();
  }
}
