import { Controller, Get, Query, Req, UseGuards } from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { MoodForecastService } from './mood-forecast.service';

@Controller('mood-forecast')
@UseGuards(AuthGuard('jwt'))
export class MoodForecastController {
  constructor(private readonly service: MoodForecastService) {}

  @Get('me/predictions')
  getPredictions(@Req() req, @Query('days') days?: string) {
    return this.service.getForecast(req.user.id, days ? +days : 7);
  }
}
