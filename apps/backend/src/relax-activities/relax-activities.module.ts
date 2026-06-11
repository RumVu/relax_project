import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { MoodCheckinsModule } from '../mood-checkins/mood-checkins.module';
import { UsersModule } from '../users/users.module';
import { RelaxActivitiesController } from './relax-activities.controller';
import { RelaxActivitiesService } from './relax-activities.service';
import { AchievementsModule } from '../achievements/achievements.module';
import { FeedModule } from '../feed/feed.module';

@Module({
  imports: [
    AuthCoreModule,
    UsersModule,
    MoodCheckinsModule,
    AchievementsModule,
    FeedModule,
  ],
  controllers: [RelaxActivitiesController],
  providers: [RelaxActivitiesService],
  exports: [RelaxActivitiesService],
})
export class RelaxActivitiesModule {}
