import { ApiProperty } from '@nestjs/swagger';

export class WeatherGreetingDto {
  @ApiProperty() title!: string;
  @ApiProperty() subtitle!: string;
  @ApiProperty() iconKey!: string;
}

export class WeatherLocationDto {
  @ApiProperty({ type: 'number' }) latitude!: number;
  @ApiProperty({ type: 'number' }) longitude!: number;
  @ApiProperty({ nullable: true }) name!: string | null;
  @ApiProperty() timezone!: string;
}

export class WeatherCurrentDataDto {
  @ApiProperty({ nullable: true, type: 'number' }) temperature!: number | null;
  @ApiProperty() temperatureUnit!: string;
  @ApiProperty({ nullable: true, type: 'integer' }) weatherCode!: number | null;
  @ApiProperty() isDay!: boolean;
  @ApiProperty({ nullable: true }) observedAt!: string | null;
}

export class WeatherForecastDayDto {
  @ApiProperty() date!: string;
  @ApiProperty({ nullable: true, type: 'number' }) temperatureMax!:
    | number
    | null;
  @ApiProperty({ nullable: true, type: 'number' }) temperatureMin!:
    | number
    | null;
  @ApiProperty({ nullable: true, type: 'integer' }) precipitationProbability!:
    | number
    | null;
  @ApiProperty({ nullable: true, type: 'integer' }) weatherCode!: number | null;
}

/**
 * Multi-shape response: when `configured` is false, only `reason` and
 * `greeting` are present; when true, `provider`, `location`, `current`, and
 * optional `reverseGeocode` are populated. All upper-level fields are
 * documented as optional so the OpenAPI schema covers both branches.
 */
export class WeatherCurrentResponseDto {
  @ApiProperty() configured!: boolean;
  @ApiProperty({ required: false }) reason?: string;
  @ApiProperty({ type: () => WeatherGreetingDto, required: false })
  greeting?: WeatherGreetingDto;
  @ApiProperty({ required: false }) provider?: string;
  @ApiProperty({ type: () => WeatherLocationDto, required: false })
  location?: WeatherLocationDto;
  @ApiProperty({ nullable: true, required: false }) reverseGeocode?: Record<
    string,
    unknown
  > | null;
  @ApiProperty({ type: () => WeatherCurrentDataDto, required: false })
  current?: WeatherCurrentDataDto;
}

export class WeatherForecastResponseDto {
  @ApiProperty() configured!: boolean;
  @ApiProperty({ required: false }) reason?: string;
  @ApiProperty({ type: () => WeatherGreetingDto, required: false })
  greeting?: WeatherGreetingDto;
  @ApiProperty({ required: false }) provider?: string;
  @ApiProperty({ type: () => WeatherLocationDto, required: false })
  location?: WeatherLocationDto;
  @ApiProperty({ nullable: true, required: false }) reverseGeocode?: Record<
    string,
    unknown
  > | null;
  @ApiProperty({ type: () => WeatherCurrentDataDto, required: false })
  current?: WeatherCurrentDataDto;
  @ApiProperty({ type: () => [WeatherForecastDayDto] })
  forecast!: WeatherForecastDayDto[];
}
