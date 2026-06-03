import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { AdminPricingController } from './admin-pricing.controller';
import { AdminPricingService } from './admin-pricing.service';
import { AdminUserPlanController } from './admin-user-plan.controller';
import { AdminUserPlanService } from './admin-user-plan.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [AdminPricingController, AdminUserPlanController],
  providers: [AdminPricingService, AdminUserPlanService],
  exports: [AdminPricingService, AdminUserPlanService],
})
export class AdminPricingModule {}
