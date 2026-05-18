import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { RelaxActivitiesModule } from '../relax-activities/relax-activities.module';
import { RelaxSessionsController } from './relax-sessions.controller';

@Module({
  imports: [AuthCoreModule, RelaxActivitiesModule],
  controllers: [RelaxSessionsController],
})
export class RelaxSessionsModule {}
