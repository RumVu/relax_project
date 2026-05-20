import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { QueuesController } from './queues.controller';
import { QueuesService } from './queues.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [QueuesController],
  providers: [QueuesService],
  exports: [QueuesService],
})
export class QueuesModule {}
