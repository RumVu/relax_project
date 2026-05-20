import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { RedisController } from './redis.controller';
import { RedisService } from './redis.service';

@Module({
  imports: [AuthCoreModule],
  controllers: [RedisController],
  providers: [RedisService],
  exports: [RedisService],
})
export class RedisModule {}
