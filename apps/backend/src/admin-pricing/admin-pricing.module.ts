import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { AdminPricingController } from './admin-pricing.controller';
import { AdminPricingService } from './admin-pricing.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [AdminPricingController],
  providers: [AdminPricingService],
  exports: [AdminPricingService],
})
export class AdminPricingModule {}
