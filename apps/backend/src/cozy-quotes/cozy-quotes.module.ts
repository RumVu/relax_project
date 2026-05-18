import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { CozyQuotesController } from './cozy-quotes.controller';
import { CozyQuotesService } from './cozy-quotes.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [CozyQuotesController],
  providers: [CozyQuotesService],
})
export class CozyQuotesModule {}
