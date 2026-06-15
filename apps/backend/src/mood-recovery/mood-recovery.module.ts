import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { MoodRecoveryController } from './mood-recovery.controller';
import { MoodRecoveryService } from './mood-recovery.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [MoodRecoveryController],
  providers: [MoodRecoveryService],
  exports: [MoodRecoveryService],
})
export class MoodRecoveryModule {}
