import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { QuestsController } from './quests.controller';
import { QuestsService } from './quests.service';
import { AchievementsModule } from '../achievements/achievements.module';
import { FeedModule } from '../feed/feed.module';

@Module({
  imports: [AuthCoreModule, AchievementsModule, FeedModule],
  controllers: [QuestsController],
  providers: [QuestsService],
  exports: [QuestsService],
})
export class QuestsModule {}
