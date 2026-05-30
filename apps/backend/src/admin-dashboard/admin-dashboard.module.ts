import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { RedisModule } from '../redis/redis.module';
import { AdminDashboardController } from './admin-dashboard.controller';
import { AdminDashboardService } from './admin-dashboard.service';
import { BillingAggregator } from './aggregators/billing.aggregator';
import { ContentAggregator } from './aggregators/content.aggregator';
import { EngagementAggregator } from './aggregators/engagement.aggregator';
import { OperationsAggregator } from './aggregators/operations.aggregator';

@Module({
  imports: [AuthCoreModule, RedisModule],
  controllers: [AdminDashboardController],
  providers: [
    AdminDashboardService,
    BillingAggregator,
    EngagementAggregator,
    ContentAggregator,
    OperationsAggregator,
  ],
})
export class AdminDashboardModule {}
