import { Body, Controller, Get, Patch, Query, UseGuards } from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOkResponse,
  ApiOperation,
  ApiTags,
} from '@nestjs/swagger';
import { minutes, Throttle } from '@nestjs/throttler';
import type { AuthUser } from '../auth/auth.types';
import { CurrentUser } from '../auth/decorators/current-user.decorator';
import { JwtAuthGuard } from '../auth/guards/jwt-auth.guard';
import {
  CurrentWeatherQueryDto,
  ReverseGeocodeQueryDto,
  UpdateWeatherLocationDto,
  WeatherForecastQueryDto,
} from './dto/current-weather-query.dto';
import { WeatherService } from './weather.service';

@ApiTags('Weather')
@Throttle({
  default: { ttl: minutes(1), limit: 80, blockDuration: minutes(1) },
})
@Controller('weather')
export class WeatherController {
  constructor(private readonly weatherService: WeatherService) {}

  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: 'Get current weather for the current user location',
  })
  @ApiOkResponse({
    description:
      'Weather payload for the home greeting. Query coordinates override saved preferences.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me/current')
  getMine(
    @CurrentUser() user: AuthUser,
    @Query() query: CurrentWeatherQueryDto,
  ) {
    return this.weatherService.getCurrentForUser(user.id, query);
  }

  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: 'Get weather forecast for the current user location',
  })
  @ApiOkResponse({
    description:
      'Forecast payload for the saved current user location. Query coordinates override saved preferences.',
  })
  @UseGuards(JwtAuthGuard)
  @Get('me/forecast')
  getMyForecast(
    @CurrentUser() user: AuthUser,
    @Query() query: WeatherForecastQueryDto,
  ) {
    return this.weatherService.getForecastForUser(user.id, query);
  }

  @ApiBearerAuth('access-token')
  @ApiOperation({
    summary: 'Save current user weather location preferences',
  })
  @ApiOkResponse({
    description:
      'Updated preferences with optional reverse geocoded location name and current weather payload.',
  })
  @UseGuards(JwtAuthGuard)
  @Patch('me/location')
  updateMyLocation(
    @CurrentUser() user: AuthUser,
    @Body() dto: UpdateWeatherLocationDto,
  ) {
    return this.weatherService.updateUserLocation(user.id, dto);
  }

  @ApiOperation({ summary: 'Get current weather by coordinates' })
  @ApiOkResponse({
    description: 'Weather payload for an explicit latitude and longitude.',
  })
  @ApiBearerAuth('access-token')
  @UseGuards(JwtAuthGuard)
  @Get('current')
  getCurrent(@Query() query: CurrentWeatherQueryDto) {
    return this.weatherService.getCurrentForCoordinates(query);
  }

  @ApiOperation({ summary: 'Get weather forecast by coordinates' })
  @ApiOkResponse({
    description: 'Forecast payload for an explicit latitude and longitude.',
  })
  @ApiBearerAuth('access-token')
  @UseGuards(JwtAuthGuard)
  @Get('forecast')
  getForecast(@Query() query: WeatherForecastQueryDto) {
    return this.weatherService.getForecastForCoordinates(query);
  }

  @ApiOperation({ summary: 'Reverse geocode coordinates into a location name' })
  @ApiOkResponse({
    description:
      'Reverse geocoded city/locality payload for mobile location setup.',
  })
  @ApiBearerAuth('access-token')
  @UseGuards(JwtAuthGuard)
  @Get('reverse-geocode')
  reverseGeocode(@Query() query: ReverseGeocodeQueryDto) {
    return this.weatherService.reverseGeocode(query);
  }
}
