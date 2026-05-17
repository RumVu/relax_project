import { Module } from '@nestjs/common';
import { BreakSessionsController } from './break-sessions.controller';
import { BreakSessionsService } from './break-sessions.service';

@Module({
  controllers: [BreakSessionsController],
  providers: [BreakSessionsService],
})
export class BreakSessionsModule {}
