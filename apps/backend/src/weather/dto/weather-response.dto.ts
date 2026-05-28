export class WeatherGreetingDto {
  title!: string;
  subtitle!: string;
  iconKey!: string;
}

export class WeatherLocationDto {
  latitude!: number;
  longitude!: number;
  name!: string | null;
  timezone!: string;
}

export class WeatherCurrentDataDto {
  temperature!: number | null;
  temperatureUnit!: string;
  weatherCode!: number | null;
  isDay!: boolean;
  observedAt!: string | null;
}

export class WeatherForecastDayDto {
  date!: string;
  temperatureMax!: number | null;
  temperatureMin!: number | null;
  precipitationProbability!: number | null;
  weatherCode!: number | null;
}

/**
 * Multi-shape response: when `configured` is false, only `reason` and
 * `greeting` are present; when true, `provider`, `location`, `current`, and
 * optional `reverseGeocode` are populated. All upper-level fields are
 * documented as optional so the OpenAPI schema covers both branches.
 */
export class WeatherCurrentResponseDto {
  configured!: boolean;
  reason?: string;
  greeting?: WeatherGreetingDto;
  provider?: string;
  location?: WeatherLocationDto;
  reverseGeocode?: Record<string, unknown> | null;
  current?: WeatherCurrentDataDto;
}

export class WeatherForecastResponseDto {
  configured!: boolean;
  reason?: string;
  greeting?: WeatherGreetingDto;
  provider?: string;
  location?: WeatherLocationDto;
  reverseGeocode?: Record<string, unknown> | null;
  current?: WeatherCurrentDataDto;
  forecast!: WeatherForecastDayDto[];
}
