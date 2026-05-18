import { Module } from '@nestjs/common';
import { UsersModule } from '../users/users.module';
import { AuthCoreModule } from './auth-core.module';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';

@Module({
  imports: [AuthCoreModule, UsersModule],
  controllers: [AuthController],
  providers: [AuthService],
  exports: [AuthService, AuthCoreModule],
})
export class AuthModule {}
