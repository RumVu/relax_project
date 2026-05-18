import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { AmbientSoundsController } from './ambient-sounds.controller';
import { AmbientSoundsService } from './ambient-sounds.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [AmbientSoundsController],
  providers: [AmbientSoundsService],
})
export class AmbientSoundsModule {}
