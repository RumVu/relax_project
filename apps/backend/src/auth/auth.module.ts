import { Module } from '@nestjs/common';
import { NotificationsModule } from '../notifications/notifications.module';
import { UsersModule } from '../users/users.module';
import { AuthCoreModule } from './auth-core.module';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { AccountTokensService } from './tokens/account-tokens.service';
import { UserExportService } from './export/user-export.service';

@Module({
  imports: [AuthCoreModule, UsersModule, NotificationsModule],
  controllers: [AuthController],
  providers: [AuthService, AccountTokensService, UserExportService],
  exports: [AuthService, AuthCoreModule],
})
export class AuthModule {}
