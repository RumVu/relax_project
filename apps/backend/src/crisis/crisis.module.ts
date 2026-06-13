import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { CrisisController } from './crisis.controller';
import { CrisisService } from './crisis.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [CrisisController],
  providers: [CrisisService],
  exports: [CrisisService],
})
export class CrisisModule {}
