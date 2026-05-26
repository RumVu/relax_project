import { HttpStatus, Injectable } from '@nestjs/common';
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

const CURRENT_WEATHER_CACHE_TTL_SECONDS = 10 * 60;
const FORECAST_CACHE_TTL_SECONDS = 30 * 60;
const REVERSE_GEOCODE_CACHE_TTL_SECONDS = 24 * 60 * 60;

interface OpenMeteoCurrentPayload {
  current?: {
    temperature_2m?: number;
    weather_code?: number;
    is_day?: number;
    time?: string;
  };
  current_units?: {
    temperature_2m?: string;
  };
  timezone?: string;
}

interface OpenMeteoForecastPayload extends OpenMeteoCurrentPayload {
  daily?: {
    time?: string[];
    weather_code?: number[];
    temperature_2m_max?: number[];
    temperature_2m_min?: number[];
    precipitation_probability_max?: number[];
  };
  daily_units?: {
    temperature_2m_max?: string;
    temperature_2m_min?: string;
    precipitation_probability_max?: string;
  };
}

interface WeatherInput {
  latitude?: number | null;
  longitude?: number | null;
  timezone: string;
  locationName?: string | null;
  weatherEnabled: boolean;
  displayName?: string | null;
}

interface ReverseGeocodePayload {
  city?: string;
  locality?: string;
  principalSubdivision?: string;
  countryName?: string;
  countryCode?: string;
  latitude?: number;
  longitude?: number;
  lookupSource?: string;
}

export interface ReverseGeocodeResult {
  provider: 'bigdatacloud';
  latitude: number;
  longitude: number;
  locationName: string | null;
  city: string | null;
  locality: string | null;
  principalSubdivision: string | null;
  countryName: string | null;
  countryCode: string | null;
  lookupSource: string | null;
}

@Injectable()
export class WeatherService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly redisService: RedisService,
  ) {}

  async getCurrentForUser(userId: string, query: CurrentWeatherQueryDto) {
    const user = await this.getExistingUserWeatherContext(userId);
    const preferences = user?.preferences;

    const latitude = query.latitude ?? preferences?.latitude;
    const longitude = query.longitude ?? preferences?.longitude;
    const timezone = normalizeTimezone(query.timezone ?? preferences?.timezone);

    return this.getCurrent({
      latitude,
      longitude,
      timezone,
      locationName: preferences?.locationName,
      weatherEnabled: preferences?.weatherEnabled ?? true,
      displayName: this.resolveDisplayName(user),
    });
  }

  async getCurrentForCoordinates(query: CurrentWeatherQueryDto) {
    return this.getCurrent({
      latitude: query.latitude,
      longitude: query.longitude,
      timezone: normalizeTimezone(query.timezone),
      weatherEnabled: true,
    });
  }

  async getForecastForUser(userId: string, query: WeatherForecastQueryDto) {
    const user = await this.getExistingUserWeatherContext(userId);
    const preferences = user?.preferences;

    const latitude = query.latitude ?? preferences?.latitude;
    const longitude = query.longitude ?? preferences?.longitude;
    const timezone = normalizeTimezone(query.timezone ?? preferences?.timezone);

    return this.getForecast({
      latitude,
      longitude,
      timezone,
      locationName: preferences?.locationName,
      weatherEnabled: preferences?.weatherEnabled ?? true,
      displayName: this.resolveDisplayName(user),
      forecastDays: query.forecastDays,
    });
  }

  async getForecastForCoordinates(query: WeatherForecastQueryDto) {
    return this.getForecast({
      latitude: query.latitude,
      longitude: query.longitude,
      timezone: normalizeTimezone(query.timezone),
      weatherEnabled: true,
      forecastDays: query.forecastDays,
    });
  }

  reverseGeocode(query: ReverseGeocodeQueryDto) {
    return this.fetchReverseGeocode(
      query.latitude,
      query.longitude,
      query.localityLanguage,
    );
  }

  async updateUserLocation(userId: string, dto: UpdateWeatherLocationDto) {
    this.assertCoordinatePair(dto.latitude, dto.longitude);

    const user = await this.getExistingUserWeatherContext(userId);
    const currentPreferences = user?.preferences;
    const latitude = dto.latitude ?? currentPreferences?.latitude ?? null;
    const longitude = dto.longitude ?? currentPreferences?.longitude ?? null;
    const shouldReverseGeocode =
      dto.reverseGeocode !== false &&
      !dto.locationName &&
      latitude != null &&
      longitude != null;
    const reverseGeocode = shouldReverseGeocode
      ? await this.fetchReverseGeocode(
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

  private async getCurrent(input: WeatherInput) {
    if (!input.weatherEnabled) {
      return {
        configured: false,
        reason: 'WEATHER_DISABLED',
        greeting: this.buildFallbackGreeting(input.timezone, input.displayName),
      };
    }

    if (input.latitude == null || input.longitude == null) {
      return {
        configured: false,
        reason: 'LOCATION_MISSING',
        greeting: this.buildFallbackGreeting(input.timezone, input.displayName),
      };
    }

    const [payload, reverseGeocode] = await Promise.all([
      this.fetchOpenMeteo(input.latitude, input.longitude, input.timezone),
      this.resolveReverseGeocode(input),
    ]);
    const current = payload.current;
    const weather = this.describeWeather(
      current?.weather_code ?? 0,
      current?.is_day !== 0,
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
      current: {
        temperature: current?.temperature_2m ?? null,
        temperatureUnit: payload.current_units?.temperature_2m ?? '°C',
        weatherCode: current?.weather_code ?? null,
        isDay: current?.is_day !== 0,
        observedAt: current?.time ?? null,
      },
      greeting: this.buildGreeting(weather, input.displayName),
    };
  }

  private async fetchOpenMeteo(
    latitude: number,
    longitude: number,
    timezone: string,
  ) {
    return this.redisService.remember(
      [
        'weather',
        'current',
        this.coordinateCachePart(latitude),
        this.coordinateCachePart(longitude),
        timezone,
      ].join(':'),
      CURRENT_WEATHER_CACHE_TTL_SECONDS,
      () => this.fetchOpenMeteoDirect(latitude, longitude, timezone),
    );
  }

  private async fetchOpenMeteoDirect(
    latitude: number,
    longitude: number,
    timezone: string,
  ): Promise<OpenMeteoCurrentPayload> {
    const url = new URL('https://api.open-meteo.com/v1/forecast');
    url.searchParams.set('latitude', String(latitude));
    url.searchParams.set('longitude', String(longitude));
    url.searchParams.set('current', 'temperature_2m,weather_code,is_day');
    url.searchParams.set('timezone', timezone);

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 5000);

    try {
      const response = await fetch(url, { signal: controller.signal });

      if (!response.ok) {
        return { current: {}, current_units: {}, timezone };
      }

      return (await response.json()) as OpenMeteoCurrentPayload;
    } catch {
      return { current: {}, current_units: {}, timezone };
    } finally {
      clearTimeout(timeout);
    }
  }

  private async getForecast(input: {
    latitude?: number | null;
    longitude?: number | null;
    timezone: string;
    locationName?: string | null;
    weatherEnabled: boolean;
    displayName?: string | null;
    forecastDays?: number;
  }) {
    if (!input.weatherEnabled) {
      return {
        configured: false,
        reason: 'WEATHER_DISABLED',
        forecast: [],
        greeting: this.buildFallbackGreeting(input.timezone, input.displayName),
      };
    }

    if (input.latitude == null || input.longitude == null) {
      return {
        configured: false,
        reason: 'LOCATION_MISSING',
        forecast: [],
        greeting: this.buildFallbackGreeting(input.timezone, input.displayName),
      };
    }

    const forecastDays = input.forecastDays ?? 7;
    const [payload, reverseGeocode] = await Promise.all([
      this.fetchOpenMeteoForecast(
        input.latitude,
        input.longitude,
        input.timezone,
        forecastDays,
      ),
      this.resolveReverseGeocode(input),
    ]);
    const current = payload.current;
    const weather = this.describeWeather(
      current?.weather_code ?? payload.daily?.weather_code?.[0] ?? 0,
      current?.is_day !== 0,
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
      current: {
        temperature: current?.temperature_2m ?? null,
        temperatureUnit: payload.current_units?.temperature_2m ?? '°C',
        weatherCode: current?.weather_code ?? null,
        isDay: current?.is_day !== 0,
        observedAt: current?.time ?? null,
      },
      forecast: this.mapDailyForecast(payload),
      greeting: this.buildGreeting(weather, input.displayName),
    };
  }

  private async fetchOpenMeteoForecast(
    latitude: number,
    longitude: number,
    timezone: string,
    forecastDays: number,
  ) {
    return this.redisService.remember(
      [
        'weather',
        'forecast',
        this.coordinateCachePart(latitude),
        this.coordinateCachePart(longitude),
        timezone,
        forecastDays,
      ].join(':'),
      FORECAST_CACHE_TTL_SECONDS,
      () =>
        this.fetchOpenMeteoForecastDirect(
          latitude,
          longitude,
          timezone,
          forecastDays,
        ),
    );
  }

  private async fetchOpenMeteoForecastDirect(
    latitude: number,
    longitude: number,
    timezone: string,
    forecastDays: number,
  ): Promise<OpenMeteoForecastPayload> {
    const url = new URL('https://api.open-meteo.com/v1/forecast');
    url.searchParams.set('latitude', String(latitude));
    url.searchParams.set('longitude', String(longitude));
    url.searchParams.set('current', 'temperature_2m,weather_code,is_day');
    url.searchParams.set(
      'daily',
      'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max',
    );
    url.searchParams.set('timezone', timezone);
    url.searchParams.set('forecast_days', String(forecastDays));

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 5000);

    try {
      const response = await fetch(url, { signal: controller.signal });

      if (!response.ok) {
        return { current: {}, current_units: {}, daily: {}, timezone };
      }

      return (await response.json()) as OpenMeteoForecastPayload;
    } catch {
      return { current: {}, current_units: {}, daily: {}, timezone };
    } finally {
      clearTimeout(timeout);
    }
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

    return this.fetchReverseGeocode(input.latitude, input.longitude);
  }

  private async fetchReverseGeocode(
    latitude: number,
    longitude: number,
    localityLanguage = 'vi',
  ): Promise<ReverseGeocodeResult | null> {
    return this.redisService.remember(
      [
        'weather',
        'reverse-geocode',
        this.coordinateCachePart(latitude),
        this.coordinateCachePart(longitude),
        localityLanguage,
      ].join(':'),
      REVERSE_GEOCODE_CACHE_TTL_SECONDS,
      () =>
        this.fetchReverseGeocodeDirect(latitude, longitude, localityLanguage),
    );
  }

  private async fetchReverseGeocodeDirect(
    latitude: number,
    longitude: number,
    localityLanguage = 'vi',
  ): Promise<ReverseGeocodeResult | null> {
    const url = new URL(
      'https://api.bigdatacloud.net/data/reverse-geocode-client',
    );
    url.searchParams.set('latitude', String(latitude));
    url.searchParams.set('longitude', String(longitude));
    url.searchParams.set('localityLanguage', localityLanguage);

    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 5000);

    try {
      const response = await fetch(url, { signal: controller.signal });

      if (!response.ok) {
        return null;
      }

      const payload = (await response.json()) as ReverseGeocodePayload;

      return {
        provider: 'bigdatacloud',
        latitude,
        longitude,
        locationName: this.buildLocationName(payload),
        city: payload.city ?? null,
        locality: payload.locality ?? null,
        principalSubdivision: payload.principalSubdivision ?? null,
        countryName: payload.countryName ?? null,
        countryCode: payload.countryCode ?? null,
        lookupSource: payload.lookupSource ?? null,
      };
    } catch {
      return null;
    } finally {
      clearTimeout(timeout);
    }
  }

  private buildLocationName(payload: ReverseGeocodePayload) {
    return (
      payload.city ||
      payload.locality ||
      payload.principalSubdivision ||
      payload.countryName ||
      null
    );
  }

  private coordinateCachePart(value: number) {
    return value.toFixed(4);
  }

  private assertCoordinatePair(
    latitude?: number | null,
    longitude?: number | null,
  ) {
    if (
      (latitude == null && longitude != null) ||
      (latitude != null && longitude == null)
    ) {
      throw new AppException(
        ErrorCode.VALIDATION_FAILED,
        'Latitude and longitude must be provided together',
        HttpStatus.BAD_REQUEST,
      );
    }
  }

  private mapDailyForecast(payload: OpenMeteoForecastPayload) {
    const daily = payload.daily;
    const dates = daily?.time ?? [];

    return dates.map((date, index) => {
      const weatherCode = daily?.weather_code?.[index] ?? null;
      const weather = this.describeWeather(weatherCode ?? 0, true);

      return {
        date,
        weatherCode,
        iconKey: weather.iconKey,
        title: this.buildForecastTitle(weather),
        temperatureMax: daily?.temperature_2m_max?.[index] ?? null,
        temperatureMin: daily?.temperature_2m_min?.[index] ?? null,
        temperatureUnit: payload.daily_units?.temperature_2m_max ?? '°C',
        precipitationProbability:
          daily?.precipitation_probability_max?.[index] ?? null,
        precipitationProbabilityUnit:
          payload.daily_units?.precipitation_probability_max ?? '%',
      };
    });
  }

  private describeWeather(code: number, isDay: boolean) {
    if (!isDay) {
      return {
        titleTemplate: 'Khuya rồi nè, {{name}} ơi',
        subtitle: 'Đừng thức khuya quá đó nha ~',
        iconKey: 'weather-night',
      };
    }

    if (code === 0 || code === 1) {
      return {
        titleTemplate: 'Đã trở lại rồi nè, {{name}} ~',
        subtitle: 'Trời nắng đẹp ghê!',
        iconKey: 'weather-sunny',
      };
    }

    if (code >= 51 && code <= 67) {
      return {
        title: 'Mưa nhẹ ngoài kia rồi nè',
        subtitle: 'Ở yên một chút cho lòng dịu lại nha ~',
        iconKey: 'weather-rain',
      };
    }

    if (code >= 80 && code <= 99) {
      return {
        title: 'Trời đang hơi ồn ào đó',
        subtitle: 'Mình chậm lại một nhịp nha ~',
        iconKey: 'weather-storm',
      };
    }

    return {
      titleTemplate: 'Đã trở lại rồi nè, {{name}} ~',
      subtitle: 'Thời tiết hôm nay cũng hợp để chill đó.',
      iconKey: 'weather-cloudy',
    };
  }

  private buildFallbackGreeting(timezone: string, displayName?: string | null) {
    const hour = Number(
      new Intl.DateTimeFormat('en-US', {
        hour: '2-digit',
        hourCycle: 'h23',
        timeZone: timezone,
      }).format(new Date()),
    );

    if (hour >= 21 || hour < 5) {
      return this.buildGreeting(
        {
          titleTemplate: 'Khuya rồi nè, {{name}} ơi',
          subtitle: 'Đừng thức khuya quá đó nha ~',
          iconKey: 'weather-night',
        },
        displayName,
      );
    }

    return this.buildGreeting(
      {
        titleTemplate: 'Đã trở lại rồi nè, {{name}} ~',
        subtitle: 'Hôm nay mình chăm sóc cảm xúc một chút nha.',
        iconKey: 'weather-default',
      },
      displayName,
    );
  }

  private buildGreeting(
    weather: {
      title?: string;
      titleTemplate?: string;
      subtitle: string;
      iconKey: string;
    },
    displayName?: string | null,
  ) {
    const name = displayName?.trim() || 'bạn';
    const titleTemplate = weather.titleTemplate ?? weather.title ?? '';

    return {
      title: titleTemplate.replace('{{name}}', name),
      titleTemplate,
      displayName: displayName?.trim() || null,
      subtitle: weather.subtitle,
      iconKey: weather.iconKey,
    };
  }

  private buildForecastTitle(weather: { title?: string; iconKey: string }) {
    if (weather.title) {
      return weather.title;
    }

    if (weather.iconKey === 'weather-sunny') return 'Trời nắng đẹp';
    if (weather.iconKey === 'weather-night') return 'Trời đã về khuya';
    if (weather.iconKey === 'weather-cloudy') return 'Trời dịu nhẹ';

    return 'Thời tiết hôm nay';
  }

  private async getUserWeatherContext(userId: string) {
    return this.prisma.user.findUnique({
      where: { id: userId },
      select: {
        name: true,
        profile: {
          select: {
            displayName: true,
          },
        },
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
      profile?: {
        displayName?: string | null;
      } | null;
    } | null,
  ) {
    return user?.profile?.displayName || user?.name || null;
  }
}
