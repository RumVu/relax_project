import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { MoodCheckinsModule } from '../mood-checkins/mood-checkins.module';
import { JournalsModule } from '../journals/journals.module';
import { RelaxActivitiesModule } from '../relax-activities/relax-activities.module';
import { UserCompanionsModule } from '../user-companions/user-companions.module';
import { AnalyticsController } from './analytics.controller';
import { AnalyticsService } from './analytics.service';

@Module({
  imports: [
    AuthCoreModule,
    MoodCheckinsModule,
    JournalsModule,
    RelaxActivitiesModule,
    UserCompanionsModule,
  ],
  controllers: [AnalyticsController],
  providers: [AnalyticsService],
})
export class AnalyticsModule {}
