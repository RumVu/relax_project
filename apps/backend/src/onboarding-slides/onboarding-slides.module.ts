import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { OnboardingSlidesController } from './onboarding-slides.controller';
import { OnboardingSlidesService } from './onboarding-slides.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [OnboardingSlidesController],
  providers: [OnboardingSlidesService],
})
export class OnboardingSlidesModule {}
