import { Module } from '@nestjs/common';
import { BuddyCircleService } from './buddy-circle.service';
import { BuddyCircleController } from './buddy-circle.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { AuthCoreModule } from '../auth/auth-core.module';

@Module({
  imports: [PrismaModule, AuthCoreModule],
  providers: [BuddyCircleService],
  controllers: [BuddyCircleController],
  exports: [BuddyCircleService],
})
export class BuddyCircleModule {}
