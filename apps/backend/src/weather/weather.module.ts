import { Module } from '@nestjs/common';
import { AuthCoreModule } from '../auth/auth-core.module';
import { RedisModule } from '../redis/redis.module';
import { WeatherController } from './weather.controller';
import { WeatherService } from './weather.service';

@Module({
  imports: [AuthCoreModule, RedisModule],
  controllers: [WeatherController],
  providers: [WeatherService],
})
export class WeatherModule {}
