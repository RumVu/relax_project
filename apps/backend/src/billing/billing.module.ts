import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { UsersModule } from '../users/users.module';
import { BillingController } from './billing.controller';
import { BillingService } from './billing.service';
import { SepayService } from './sepay.service';

@Module({
  imports: [AuthCoreModule, UsersModule],
  controllers: [BillingController],
  providers: [BillingService, SepayService],
  exports: [SepayService],
})
export class BillingModule {}
