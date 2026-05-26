import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { RedisModule } from '../redis/redis.module';
import { AdminDashboardController } from './admin-dashboard.controller';
import { AdminDashboardService } from './admin-dashboard.service';

@Module({
  imports: [AuthCoreModule, RedisModule],
  controllers: [AdminDashboardController],
  providers: [AdminDashboardService],
})
export class AdminDashboardModule {}
