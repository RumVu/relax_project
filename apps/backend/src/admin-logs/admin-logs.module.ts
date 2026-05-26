import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { AdminLogsController } from './admin-logs.controller';
import { AdminLogsService } from './admin-logs.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [AdminLogsController],
  providers: [AdminLogsService],
})
export class AdminLogsModule {}
