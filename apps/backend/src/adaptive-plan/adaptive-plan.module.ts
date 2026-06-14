import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { AuthCoreModule } from '../auth/auth-core.module';
import { AdaptivePlanController } from './adaptive-plan.controller';
import { AdaptivePlanService } from './adaptive-plan.service';

@Module({
  imports: [PrismaModule, AuthCoreModule],
  controllers: [AdaptivePlanController],
  providers: [AdaptivePlanService],
  exports: [AdaptivePlanService],
})
export class AdaptivePlanModule {}
