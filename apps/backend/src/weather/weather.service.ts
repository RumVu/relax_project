import { Injectable } from '@nestjs/common';
import { AppException } from '../common/errors/app.exception';
import { ErrorCode } from '../common/errors/error-code';
import { normalizeTimezone } from '../common/timezone';
import { PrismaService } from '../prisma/prisma.service';
import { RedisService } from '../redis/redis.service';
import {
  CurrentWeatherQueryDto,
  ReverseGeocodeQueryDto,
  UpdateWeatherLocationDto,
  WeatherForecastQueryDto,
} from './dto/current-weather-query.dto';

import {
  OpenMeteoCurrentPayload,
  OpenMeteoForecastPayload,
  fetchCurrentWeather,
  fetchForecast,
} from './clients/open-meteo.client';
import {
  ReverseGeocodeResult,
  fetchReverseGeocode,
} from './clients/reverse-geocode.client';
import { describeWeather } from './helpers/weather-description';
import {
  buildFallbackGreeting,
  buildGreeting,
} from './helpers/weather-greeting';
import {
  coordinateCachePart,
  mapCurrentSnapshot,
  mapDailyForecast,
} from './helpers/weather-mapper';
import { assertCoordinatePair } from './helpers/weather-validation';

const CURRENT_WEATHER_CACHE_TTL_SECONDS = 10 * 60;
const FORECAST_CACHE_TTL_SECONDS = 30 * 60;
const REVERSE_GEOCODE_CACHE_TTL_SECONDS = 24 * 60 * 60;

interface WeatherInput {
  latitude?: number | null;
  longitude?: number | null;
  timezone: string;
  locationName?: string | null;
  weatherEnabled: boolean;
  displayName?: string | null;
}

interface ForecastInput extends WeatherInput {
  forecastDays?: number;
}

/**
 * WeatherService — orchestrator mỏng.
 *
 * Splits:
 *   - clients/open-meteo.client.ts        Open-Meteo HTTP (timeout, fallback)
 *   - clients/reverse-geocode.client.ts   BigDataCloud HTTP
 *   - helpers/weather-description.ts      WMO code → vi label + icon
 *   - helpers/weather-greeting.ts         display name + weather → hero card
 *   - helpers/weather-mapper.ts           Open-Meteo payload → API DTO
 *   - helpers/weather-validation.ts       lat/lng pair guard
 *
 * Service giữ: Prisma access, Redis caching, orchestration.
 */
@Injectable()
export class WeatherService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redisService: RedisService,
  ) {}

  // ============================================================
  // PUBLIC
  // ============================================================

  async getCurrentForUser(userId: string, query: CurrentWeatherQueryDto) {
    const user = await this.getExistingUserWeatherContext(userId);
    const preferences = user.preferences;

    return this.getCurrent({
      latitude: query.latitude ?? preferences?.latitude,
      longitude: query.longitude ?? preferences?.longitude,
      timezone: normalizeTimezone(query.timezone ?? preferences?.timezone),
      locationName: preferences?.locationName,
      weatherEnabled: preferences?.weatherEnabled ?? true,
      displayName: this.resolveDisplayName(user),
    });
  }

  getCurrentForCoordinates(query: CurrentWeatherQueryDto) {
    return this.getCurrent({
      latitude: query.latitude,
      longitude: query.longitude,
      timezone: normalizeTimezone(query.timezone),
      weatherEnabled: true,
    });
  }

  async getForecastForUser(userId: string, query: WeatherForecastQueryDto) {
    const user = await this.getExistingUserWeatherContext(userId);
    const preferences = user.preferences;

    return this.getForecast({
      latitude: query.latitude ?? preferences?.latitude,
      longitude: query.longitude ?? preferences?.longitude,
      timezone: normalizeTimezone(query.timezone ?? preferences?.timezone),
      locationName: preferences?.locationName,
      weatherEnabled: preferences?.weatherEnabled ?? true,
      displayName: this.resolveDisplayName(user),
      forecastDays: query.forecastDays,
    });
  }

  getForecastForCoordinates(query: WeatherForecastQueryDto) {
    return this.getForecast({
      latitude: query.latitude,
      longitude: query.longitude,
      timezone: normalizeTimezone(query.timezone),
      weatherEnabled: true,
      forecastDays: query.forecastDays,
    });
  }

  reverseGeocode(query: ReverseGeocodeQueryDto) {
    return this.cachedReverseGeocode(
      query.latitude,
      query.longitude,
      query.localityLanguage,
    );
  }

  async updateUserLocation(userId: string, dto: UpdateWeatherLocationDto) {
    assertCoordinatePair(dto.latitude, dto.longitude);

    const user = await this.getExistingUserWeatherContext(userId);
    const currentPreferences = user.preferences;
    const latitude = dto.latitude ?? currentPreferences?.latitude ?? null;
    const longitude = dto.longitude ?? currentPreferences?.longitude ?? null;
    const shouldReverseGeocode =
      dto.reverseGeocode !== false &&
      !dto.locationName &&
      latitude != null &&
      longitude != null;
    const reverseGeocode = shouldReverseGeocode
      ? await this.cachedReverseGeocode(
          latitude,
          longitude,
          dto.localityLanguage,
        )
      : null;
    const timezone = normalizeTimezone(
      dto.timezone ?? currentPreferences?.timezone,
    );
    const locationName =
      dto.locationName?.trim() ||
      reverseGeocode?.locationName ||
      currentPreferences?.locationName ||
      null;

    const preferences = await this.prisma.userPreference.upsert({
      where: { userId },
      create: {
        userId,
        latitude,
        longitude,
        timezone,
        locationName,
        weatherEnabled: dto.weatherEnabled ?? true,
      },
      update: {
        latitude,
        longitude,
        timezone,
        locationName,
        weatherEnabled:
          dto.weatherEnabled ?? currentPreferences?.weatherEnabled,
      },
    });

    return {
      preferences,
      reverseGeocode,
      weather: await this.getCurrentForUser(userId, {}),
    };
  }

  // ============================================================
  // PRIVATE — orchestration
  // ============================================================

  private async getCurrent(input: WeatherInput) {
    if (!input.weatherEnabled) {
      return {
        configured: false,
        reason: 'WEATHER_DISABLED',
        greeting: buildFallbackGreeting(input.timezone, input.displayName),
      };
    }

    if (input.latitude == null || input.longitude == null) {
      return {
        configured: false,
        reason: 'LOCATION_MISSING',
        greeting: buildFallbackGreeting(input.timezone, input.displayName),
      };
    }

    const [payload, reverseGeocode] = await Promise.all([
      this.cachedCurrentWeather(
        input.latitude,
        input.longitude,
        input.timezone,
      ),
      this.resolveReverseGeocode(input),
    ]);
    const hasCurrent =
      payload.current && Object.keys(payload.current).length > 0;
    const hour = Number(
      new Intl.DateTimeFormat('en-US', {
        hour: '2-digit',
        hourCycle: 'h23',
        timeZone: input.timezone,
      }).format(new Date()),
    );
    const isDay =
      hasCurrent && payload.current?.is_day !== undefined
        ? payload.current.is_day !== 0
        : hour >= 6 && hour < 18;
    const weather = describeWeather(
      payload.current?.weather_code ?? (isDay ? 1 : 0),
      isDay,
    );

    return {
      configured: true,
      provider: 'open-meteo',
      location: {
        latitude: input.latitude,
        longitude: input.longitude,
        name: input.locationName ?? reverseGeocode?.locationName ?? null,
        timezone: payload.timezone ?? input.timezone,
      },
      reverseGeocode,
      current: mapCurrentSnapshot(payload),
      greeting: buildGreeting(weather, input.displayName),
    };
  }

  private async getForecast(input: ForecastInput) {
    if (!input.weatherEnabled) {
      return {
        configured: false,
        reason: 'WEATHER_DISABLED',
        forecast: [],
        greeting: buildFallbackGreeting(input.timezone, input.displayName),
      };
    }

    if (input.latitude == null || input.longitude == null) {
      return {
        configured: false,
        reason: 'LOCATION_MISSING',
        forecast: [],
        greeting: buildFallbackGreeting(input.timezone, input.displayName),
      };
    }

    const forecastDays = input.forecastDays ?? 7;
    const [payload, reverseGeocode] = await Promise.all([
      this.cachedForecast(
        input.latitude,
        input.longitude,
        input.timezone,
        forecastDays,
      ),
      this.resolveReverseGeocode(input),
    ]);
    const hasCurrent =
      payload.current && Object.keys(payload.current).length > 0;
    const hour = Number(
      new Intl.DateTimeFormat('en-US', {
        hour: '2-digit',
        hourCycle: 'h23',
        timeZone: input.timezone,
      }).format(new Date()),
    );
    const isDay =
      hasCurrent && payload.current?.is_day !== undefined
        ? payload.current.is_day !== 0
        : hour >= 6 && hour < 18;
    const weather = describeWeather(
      payload.current?.weather_code ??
        payload.daily?.weather_code?.[0] ??
        (isDay ? 1 : 0),
      isDay,
    );

    return {
      configured: true,
      provider: 'open-meteo',
      location: {
        latitude: input.latitude,
        longitude: input.longitude,
        name: input.locationName ?? reverseGeocode?.locationName ?? null,
        timezone: payload.timezone ?? input.timezone,
      },
      reverseGeocode,
      current: mapCurrentSnapshot(payload),
      forecast: mapDailyForecast(payload),
      greeting: buildGreeting(weather, input.displayName),
    };
  }

  // ============================================================
  // PRIVATE — cache wrappers
  // ============================================================

  private async cachedCurrentWeather(
    latitude: number,
    longitude: number,
    timezone: string,
  ): Promise<OpenMeteoCurrentPayload> {
    const key = [
      'weather',
      'current',
      coordinateCachePart(latitude),
      coordinateCachePart(longitude),
      timezone,
    ].join(':');

    const cached =
      await this.redisService.getJson<OpenMeteoCurrentPayload>(key);
    if (cached !== null) {
      return cached;
    }

    const value = await fetchCurrentWeather(latitude, longitude, timezone);
    if (value.current && value.current.temperature_2m !== undefined) {
      await this.redisService.setJson(
        key,
        value,
        CURRENT_WEATHER_CACHE_TTL_SECONDS,
      );
    } else {
      await this.redisService.setJson(key, value, 5);
    }
    return value;
  }

  private async cachedForecast(
    latitude: number,
    longitude: number,
    timezone: string,
    forecastDays: number,
  ): Promise<OpenMeteoForecastPayload> {
    const key = [
      'weather',
      'forecast',
      coordinateCachePart(latitude),
      coordinateCachePart(longitude),
      timezone,
      forecastDays,
    ].join(':');

    const cached =
      await this.redisService.getJson<OpenMeteoForecastPayload>(key);
    if (cached !== null) {
      return cached;
    }

    const value = await fetchForecast(
      latitude,
      longitude,
      timezone,
      forecastDays,
    );
    if (value.current && value.current.temperature_2m !== undefined) {
      await this.redisService.setJson(key, value, FORECAST_CACHE_TTL_SECONDS);
    } else {
      await this.redisService.setJson(key, value, 5);
    }
    return value;
  }

  private cachedReverseGeocode(
    latitude: number,
    longitude: number,
    localityLanguage = 'vi',
  ): Promise<ReverseGeocodeResult | null> {
    return this.redisService.remember(
      [
        'weather',
        'reverse-geocode',
        coordinateCachePart(latitude),
        coordinateCachePart(longitude),
        localityLanguage,
      ].join(':'),
      REVERSE_GEOCODE_CACHE_TTL_SECONDS,
      () => fetchReverseGeocode(latitude, longitude, localityLanguage),
    );
  }

  private async resolveReverseGeocode(input: {
    latitude?: number | null;
    longitude?: number | null;
    locationName?: string | null;
  }) {
    if (
      input.locationName ||
      input.latitude == null ||
      input.longitude == null
    ) {
      return null;
    }
    return this.cachedReverseGeocode(input.latitude, input.longitude);
  }

  // ============================================================
  // PRIVATE — DB lookups
  // ============================================================

  private getUserWeatherContext(userId: string) {
    return this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        name: true,
        profile: { select: { displayName: true } },
        preferences: {
          select: {
            latitude: true,
            longitude: true,
            locationName: true,
            timezone: true,
            weatherEnabled: true,
          },
        },
      },
    });
  }

  private async getExistingUserWeatherContext(userId: string) {
    const user = await this.getUserWeatherContext(userId);
    if (!user) {
      throw AppException.notFound(ErrorCode.USER_NOT_FOUND, 'User not found');
    }
    return user;
  }

  private resolveDisplayName(
    user: {
      name?: string | null;
      profile?: { displayName?: string | null } | null;
    } | null,
  ) {
    return user?.profile?.displayName || user?.name || null;
  }
}
