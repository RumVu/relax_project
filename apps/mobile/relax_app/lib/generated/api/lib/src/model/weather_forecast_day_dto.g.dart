// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_forecast_day_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WeatherForecastDayDto extends WeatherForecastDayDto {
  @override
  final String date;
  @override
  final num? temperatureMax;
  @override
  final num? temperatureMin;
  @override
  final num? precipitationProbability;
  @override
  final num? weatherCode;

  factory _$WeatherForecastDayDto(
          [void Function(WeatherForecastDayDtoBuilder)? updates]) =>
      (WeatherForecastDayDtoBuilder()..update(updates))._build();

  _$WeatherForecastDayDto._(
      {required this.date,
      this.temperatureMax,
      this.temperatureMin,
      this.precipitationProbability,
      this.weatherCode})
      : super._();
  @override
  WeatherForecastDayDto rebuild(
          void Function(WeatherForecastDayDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WeatherForecastDayDtoBuilder toBuilder() =>
      WeatherForecastDayDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WeatherForecastDayDto &&
        date == other.date &&
        temperatureMax == other.temperatureMax &&
        temperatureMin == other.temperatureMin &&
        precipitationProbability == other.precipitationProbability &&
        weatherCode == other.weatherCode;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, date.hashCode);
    _$hash = $jc(_$hash, temperatureMax.hashCode);
    _$hash = $jc(_$hash, temperatureMin.hashCode);
    _$hash = $jc(_$hash, precipitationProbability.hashCode);
    _$hash = $jc(_$hash, weatherCode.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WeatherForecastDayDto')
          ..add('date', date)
          ..add('temperatureMax', temperatureMax)
          ..add('temperatureMin', temperatureMin)
          ..add('precipitationProbability', precipitationProbability)
          ..add('weatherCode', weatherCode))
        .toString();
  }
}

class WeatherForecastDayDtoBuilder
    implements Builder<WeatherForecastDayDto, WeatherForecastDayDtoBuilder> {
  _$WeatherForecastDayDto? _$v;

  String? _date;
  String? get date => _$this._date;
  set date(String? date) => _$this._date = date;

  num? _temperatureMax;
  num? get temperatureMax => _$this._temperatureMax;
  set temperatureMax(num? temperatureMax) =>
      _$this._temperatureMax = temperatureMax;

  num? _temperatureMin;
  num? get temperatureMin => _$this._temperatureMin;
  set temperatureMin(num? temperatureMin) =>
      _$this._temperatureMin = temperatureMin;

  num? _precipitationProbability;
  num? get precipitationProbability => _$this._precipitationProbability;
  set precipitationProbability(num? precipitationProbability) =>
      _$this._precipitationProbability = precipitationProbability;

  num? _weatherCode;
  num? get weatherCode => _$this._weatherCode;
  set weatherCode(num? weatherCode) => _$this._weatherCode = weatherCode;

  WeatherForecastDayDtoBuilder() {
    WeatherForecastDayDto._defaults(this);
  }

  WeatherForecastDayDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _date = $v.date;
      _temperatureMax = $v.temperatureMax;
      _temperatureMin = $v.temperatureMin;
      _precipitationProbability = $v.precipitationProbability;
      _weatherCode = $v.weatherCode;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WeatherForecastDayDto other) {
    _$v = other as _$WeatherForecastDayDto;
  }

  @override
  void update(void Function(WeatherForecastDayDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WeatherForecastDayDto build() => _build();

  _$WeatherForecastDayDto _build() {
    final _$result = _$v ??
        _$WeatherForecastDayDto._(
          date: BuiltValueNullFieldError.checkNotNull(
              date, r'WeatherForecastDayDto', 'date'),
          temperatureMax: temperatureMax,
          temperatureMin: temperatureMin,
          precipitationProbability: precipitationProbability,
          weatherCode: weatherCode,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
