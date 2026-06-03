import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { AiInsightsController } from './ai-insights.controller';
import { AiInsightsService } from './ai-insights.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [AiInsightsController],
  providers: [AiInsightsService],
  exports: [AiInsightsService],
})
export class AiInsightsModule {}
