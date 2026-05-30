/**
 * Open-Meteo HTTP client. Pure — no DI, no caching here (caching is the
 * caller's job: WeatherService wraps these with RedisService.remember).
 *
 * Both fetchers swallow network/HTTP errors and return an empty-shaped
 * payload so the dashboard renders "no data" instead of bubbling 500s
 * for transient upstream blips.
 */
const OPEN_METEO_URL = 'https://api.open-meteo.com/v1/forecast';
const REQUEST_TIMEOUT_MS = 5000;
const CURRENT_FIELDS =
  'temperature_2m,apparent_temperature,relative_humidity_2m,weather_code,is_day,precipitation,wind_speed_10m,wind_direction_10m';
const DAILY_FIELDS =
  'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max';

export interface OpenMeteoCurrentPayload {
  current?: {
    temperature_2m?: number;
    apparent_temperature?: number;
    relative_humidity_2m?: number;
    weather_code?: number;
    is_day?: number;
    precipitation?: number;
    wind_speed_10m?: number;
    wind_direction_10m?: number;
    time?: string;
  };
  current_units?: {
    temperature_2m?: string;
    relative_humidity_2m?: string;
    wind_speed_10m?: string;
    precipitation?: string;
  };
  timezone?: string;
}

export interface OpenMeteoForecastPayload extends OpenMeteoCurrentPayload {
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

async function fetchWithTimeout(url: URL): Promise<Response | null> {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);

  try {
    const response = await fetch(url, { signal: controller.signal });
    return response.ok ? response : null;
  } catch {
    return null;
  } finally {
    clearTimeout(timeout);
  }
}

export async function fetchCurrentWeather(
  latitude: number,
  longitude: number,
  timezone: string,
): Promise<OpenMeteoCurrentPayload> {
  const url = new URL(OPEN_METEO_URL);
  url.searchParams.set('latitude', String(latitude));
  url.searchParams.set('longitude', String(longitude));
  url.searchParams.set('current', CURRENT_FIELDS);
  url.searchParams.set('timezone', timezone);

  const response = await fetchWithTimeout(url);
  if (!response) return { current: {}, current_units: {}, timezone };
  return (await response.json()) as OpenMeteoCurrentPayload;
}

export async function fetchForecast(
  latitude: number,
  longitude: number,
  timezone: string,
  forecastDays: number,
): Promise<OpenMeteoForecastPayload> {
  const url = new URL(OPEN_METEO_URL);
  url.searchParams.set('latitude', String(latitude));
  url.searchParams.set('longitude', String(longitude));
  url.searchParams.set('current', CURRENT_FIELDS);
  url.searchParams.set('daily', DAILY_FIELDS);
  url.searchParams.set('timezone', timezone);
  url.searchParams.set('forecast_days', String(forecastDays));

  const response = await fetchWithTimeout(url);
  if (!response) return { current: {}, current_units: {}, daily: {}, timezone };
  return (await response.json()) as OpenMeteoForecastPayload;
}
