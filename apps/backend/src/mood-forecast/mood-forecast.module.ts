import { Module } from '@nestjs/common';
import { MoodForecastService } from './mood-forecast.service';
import { MoodForecastController } from './mood-forecast.controller';
import { AuthCoreModule } from '../auth/auth-core.module';

@Module({
  imports: [AuthCoreModule],
  controllers: [MoodForecastController],
  providers: [MoodForecastService],
})
export class MoodForecastModule {}
