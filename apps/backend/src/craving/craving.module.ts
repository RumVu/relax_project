import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { CravingController } from './craving.controller';
import { CravingService } from './craving.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [CravingController],
  providers: [CravingService],
  exports: [CravingService],
})
export class CravingModule {}
