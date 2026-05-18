import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { UsersModule } from '../users/users.module';
import { BillingController } from './billing.controller';
import { BillingService } from './billing.service';

@Module({
  imports: [AuthCoreModule, UsersModule],
  controllers: [BillingController],
  providers: [BillingService],
})
export class BillingModule {}
