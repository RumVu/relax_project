import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { MoodCheckinsModule } from '../mood-checkins/mood-checkins.module';
import { UsersModule } from '../users/users.module';
import { RelaxActivitiesController } from './relax-activities.controller';
import { RelaxActivitiesService } from './relax-activities.service';

@Module({
  imports: [AuthCoreModule, UsersModule, MoodCheckinsModule],
  controllers: [RelaxActivitiesController],
  providers: [RelaxActivitiesService],
  exports: [RelaxActivitiesService],
})
export class RelaxActivitiesModule {}
