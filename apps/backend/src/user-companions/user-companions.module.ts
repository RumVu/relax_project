import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { UsersModule } from '../users/users.module';
import { UserCompanionsController } from './user-companions.controller';
import { UserCompanionsService } from './user-companions.service';

@Module({
  imports: [AuthCoreModule, UsersModule],
  controllers: [UserCompanionsController],
  providers: [UserCompanionsService],
  exports: [UserCompanionsService],
})
export class UserCompanionsModule {}
