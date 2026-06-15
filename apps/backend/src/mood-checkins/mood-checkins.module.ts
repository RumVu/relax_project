import { Module, forwardRef } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { UsersModule } from '../users/users.module';
import { MoodCheckinsController } from './mood-checkins.controller';
import { MoodCheckinsService } from './mood-checkins.service';
import { AchievementsModule } from '../achievements/achievements.module';
import { FeedModule } from '../feed/feed.module';
import { MoodGoalsModule } from '../mood-goals/mood-goals.module';

@Module({
  imports: [AuthCoreModule, UsersModule, AchievementsModule, FeedModule, forwardRef(() => MoodGoalsModule)],
  controllers: [MoodCheckinsController],
  providers: [MoodCheckinsService],
  exports: [MoodCheckinsService],
})
export class MoodCheckinsModule {}
