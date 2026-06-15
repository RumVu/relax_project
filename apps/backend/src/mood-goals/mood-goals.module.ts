import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { MoodGoalsController } from './mood-goals.controller';
import { MoodGoalsService } from './mood-goals.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [MoodGoalsController],
  providers: [MoodGoalsService],
  exports: [MoodGoalsService],
})
export class MoodGoalsModule {}
