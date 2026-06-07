import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { UsersModule } from '../users/users.module';
import { BillingController } from './billing.controller';
import { BillingService } from './billing.service';
import {
  SepayController,
  SepayLegacyController,
} from './sepay_billing/sepay_controller';
import { SepayBillingService } from './sepay_billing/sepay_billing.service';

@Module({
  imports: [AuthCoreModule, UsersModule],
  controllers: [BillingController, SepayController, SepayLegacyController],
  providers: [BillingService, SepayBillingService],
})
export class BillingModule {}
