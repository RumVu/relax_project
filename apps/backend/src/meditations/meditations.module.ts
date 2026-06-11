import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { UsersModule } from '../users/users.module';
import { MeditationsController } from './meditations.controller';
import { MeditationsService } from './meditations.service';

@Module({
  imports: [AuthCoreModule, UsersModule],
  controllers: [MeditationsController],
  providers: [MeditationsService],
  exports: [MeditationsService],
})
export class MeditationsModule {}
