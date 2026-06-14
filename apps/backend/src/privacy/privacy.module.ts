import { Module } from '@nestjs/common';
import { PrivacyService } from './privacy.service';
import { PrivacyController } from './privacy.controller';
import { PrismaModule } from '../prisma/prisma.module';
import { AuthCoreModule } from '../auth/auth-core.module';

@Module({
  imports: [PrismaModule, AuthCoreModule],
  providers: [PrivacyService],
  controllers: [PrivacyController],
  exports: [PrivacyService],
})
export class PrivacyModule {}
