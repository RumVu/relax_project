import { Type } from 'class-transformer';
import {
  IsBoolean,
  IsInt,
  IsLatitude,
  IsLongitude,
  IsOptional,
  IsString,
  Max,
  Min,
} from 'class-validator';

export class CurrentWeatherQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsLatitude()
  latitude?: number;

  @IsOptional()
  @Type(() => Number)
  @IsLongitude()
  longitude?: number;

  @IsOptional()
  @IsString()
  timezone?: string;
}

export class WeatherForecastQueryDto extends CurrentWeatherQueryDto {
  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(7)
  forecastDays?: number;
}

export class ReverseGeocodeQueryDto {
  @Type(() => Number)
  @IsLatitude()
  latitude!: number;

  @Type(() => Number)
  @IsLongitude()
  longitude!: number;

  @IsOptional()
  @IsString()
  localityLanguage?: string;
}

export class UpdateWeatherLocationDto {
  @IsOptional()
  @Type(() => Number)
  @IsLatitude()
  latitude?: number;

  @IsOptional()
  @Type(() => Number)
  @IsLongitude()
  longitude?: number;

  @IsOptional()
  @IsString()
  timezone?: string;

  @IsOptional()
  @IsString()
  locationName?: string;

  @IsOptional()
  @IsBoolean()
  weatherEnabled?: boolean;

  @IsOptional()
  @IsBoolean()
  reverseGeocode?: boolean;

  @IsOptional()
  @IsString()
  localityLanguage?: string;
}
