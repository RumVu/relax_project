import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { UsersModule } from '../users/users.module';
import { MoodCheckinsController } from './mood-checkins.controller';
import { MoodCheckinsService } from './mood-checkins.service';

@Module({
  imports: [AuthCoreModule, UsersModule],
  controllers: [MoodCheckinsController],
  providers: [MoodCheckinsService],
  exports: [MoodCheckinsService],
})
export class MoodCheckinsModule {}
