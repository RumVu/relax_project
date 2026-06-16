import type { TranslationKey } from '@/lib/i18n/dictionaries';

export type TranslationFn = (key: TranslationKey, params?: Record<string, string | number>) => string;

export type WeatherCurrent = {
  configured?: boolean;
  reason?: string;
  greeting?: {
    title?: string;
    subtitle?: string;
    iconKey?: string;
    displayName?: string;
  };
  current?: {
    temperature?: number;
    temperatureUnit?: string;
    apparentTemperature?: number;
    humidity?: number;
    humidityUnit?: string;
    windSpeed?: number;
    windSpeedUnit?: string;
    windDirection?: number;
    precipitation?: number;
    precipitationUnit?: string;
    weatherCode?: number;
    isDay?: boolean;
  };
  location?: {
    name?: string;
    latitude?: number;
    longitude?: number;
    timezone?: string;
  };
};

export type ForecastDay = {
  date: string;
  temperatureMax?: number;
  temperatureMin?: number;
  precipitationProbability?: number;
  precipitationSum?: number;
  windSpeedMax?: number;
  weatherCode?: number;
};

export type WeatherForecast = {
  configured?: boolean;
  reason?: string;
  forecast?: ForecastDay[];
  hourly?: Array<{
    time: string;
    temperature?: number;
    precipitationProbability?: number;
  }>;
};
