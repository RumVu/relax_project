/**
 * Map Open-Meteo payloads → API response shape used by the dashboard.
 * Pure mapping; no I/O, no DI.
 */
import {
  OpenMeteoCurrentPayload,
  OpenMeteoForecastPayload,
} from '../clients/open-meteo.client';
import { buildForecastTitle, describeWeather } from './weather-description';

export interface WeatherCurrentSnapshot {
  temperature: number | null;
  temperatureUnit: string;
  apparentTemperature: number | null;
  humidity: number | null;
  humidityUnit: string;
  windSpeed: number | null;
  windSpeedUnit: string;
  windDirection: number | null;
  precipitation: number | null;
  precipitationUnit: string;
  weatherCode: number | null;
  isDay: boolean;
  observedAt: string | null;
}

/** Extract the `current` block as the dashboard expects it. */
export function mapCurrentSnapshot(
  payload: OpenMeteoCurrentPayload,
): WeatherCurrentSnapshot {
  const current = payload.current;
  return {
    temperature: current?.temperature_2m ?? null,
    temperatureUnit: payload.current_units?.temperature_2m ?? '°C',
    apparentTemperature: current?.apparent_temperature ?? null,
    humidity: current?.relative_humidity_2m ?? null,
    humidityUnit: payload.current_units?.relative_humidity_2m ?? '%',
    windSpeed: current?.wind_speed_10m ?? null,
    windSpeedUnit: payload.current_units?.wind_speed_10m ?? 'km/h',
    windDirection: current?.wind_direction_10m ?? null,
    precipitation: current?.precipitation ?? null,
    precipitationUnit: payload.current_units?.precipitation ?? 'mm',
    weatherCode: current?.weather_code ?? null,
    isDay: current?.is_day !== undefined
      ? current.is_day !== 0
      : (() => {
          const tz = payload.timezone ?? 'Asia/Ho_Chi_Minh';
          try {
            const hour = Number(
              new Intl.DateTimeFormat('en-US', {
                hour: '2-digit',
                hourCycle: 'h23',
                timeZone: tz,
              }).format(new Date()),
            );
            return hour >= 6 && hour < 18;
          } catch {
            return true;
          }
        })(),
    observedAt: current?.time ?? null,
  };
}

/** Per-day forecast cards. */
export function mapDailyForecast(payload: OpenMeteoForecastPayload) {
  const daily = payload.daily;
  const dates = daily?.time ?? [];

  return dates.map((date, index) => {
    const weatherCode = daily?.weather_code?.[index] ?? null;
    const weather = describeWeather(weatherCode ?? 0, true);

    return {
      date,
      weatherCode,
      iconKey: weather.iconKey,
      title: buildForecastTitle(weather),
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

/**
 * Round to 4 decimal places (~11m). We use this as the cache key part
 * so two close-by lookups share the same cache entry — saves API calls
 * without giving up meaningful precision.
 */
export function coordinateCachePart(value: number): string {
  return value.toFixed(4);
}
