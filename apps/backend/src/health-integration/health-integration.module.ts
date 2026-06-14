import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { HealthIntegrationController } from './health-integration.controller';
import { HealthIntegrationService } from './health-integration.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [HealthIntegrationController],
  providers: [HealthIntegrationService],
  exports: [HealthIntegrationService],
})
export class HealthIntegrationModule {}
