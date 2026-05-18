import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { MoodCheckinsModule } from '../mood-checkins/mood-checkins.module';
import { JobsController } from './jobs.controller';
import { JobsService } from './jobs.service';

@Module({
  imports: [AuthCoreModule, MoodCheckinsModule],
  controllers: [JobsController],
  providers: [JobsService],
})
export class JobsModule {}
