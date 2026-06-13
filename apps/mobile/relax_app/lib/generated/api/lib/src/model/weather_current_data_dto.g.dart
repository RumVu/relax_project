// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_current_data_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WeatherCurrentDataDto extends WeatherCurrentDataDto {
  @override
  final num? temperature;
  @override
  final String temperatureUnit;
  @override
  final num? weatherCode;
  @override
  final bool isDay;
  @override
  final String? observedAt;

  factory _$WeatherCurrentDataDto(
          [void Function(WeatherCurrentDataDtoBuilder)? updates]) =>
      (WeatherCurrentDataDtoBuilder()..update(updates))._build();

  _$WeatherCurrentDataDto._(
      {this.temperature,
      required this.temperatureUnit,
      this.weatherCode,
      required this.isDay,
      this.observedAt})
      : super._();
  @override
  WeatherCurrentDataDto rebuild(
          void Function(WeatherCurrentDataDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WeatherCurrentDataDtoBuilder toBuilder() =>
      WeatherCurrentDataDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WeatherCurrentDataDto &&
        temperature == other.temperature &&
        temperatureUnit == other.temperatureUnit &&
        weatherCode == other.weatherCode &&
        isDay == other.isDay &&
        observedAt == other.observedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, temperature.hashCode);
    _$hash = $jc(_$hash, temperatureUnit.hashCode);
    _$hash = $jc(_$hash, weatherCode.hashCode);
    _$hash = $jc(_$hash, isDay.hashCode);
    _$hash = $jc(_$hash, observedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WeatherCurrentDataDto')
          ..add('temperature', temperature)
          ..add('temperatureUnit', temperatureUnit)
          ..add('weatherCode', weatherCode)
          ..add('isDay', isDay)
          ..add('observedAt', observedAt))
        .toString();
  }
}

class WeatherCurrentDataDtoBuilder
    implements Builder<WeatherCurrentDataDto, WeatherCurrentDataDtoBuilder> {
  _$WeatherCurrentDataDto? _$v;

  num? _temperature;
  num? get temperature => _$this._temperature;
  set temperature(num? temperature) => _$this._temperature = temperature;

  String? _temperatureUnit;
  String? get temperatureUnit => _$this._temperatureUnit;
  set temperatureUnit(String? temperatureUnit) =>
      _$this._temperatureUnit = temperatureUnit;

  num? _weatherCode;
  num? get weatherCode => _$this._weatherCode;
  set weatherCode(num? weatherCode) => _$this._weatherCode = weatherCode;

  bool? _isDay;
  bool? get isDay => _$this._isDay;
  set isDay(bool? isDay) => _$this._isDay = isDay;

  String? _observedAt;
  String? get observedAt => _$this._observedAt;
  set observedAt(String? observedAt) => _$this._observedAt = observedAt;

  WeatherCurrentDataDtoBuilder() {
    WeatherCurrentDataDto._defaults(this);
  }

  WeatherCurrentDataDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _temperature = $v.temperature;
      _temperatureUnit = $v.temperatureUnit;
      _weatherCode = $v.weatherCode;
      _isDay = $v.isDay;
      _observedAt = $v.observedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WeatherCurrentDataDto other) {
    _$v = other as _$WeatherCurrentDataDto;
  }

  @override
  void update(void Function(WeatherCurrentDataDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WeatherCurrentDataDto build() => _build();

  _$WeatherCurrentDataDto _build() {
    final _$result = _$v ??
        _$WeatherCurrentDataDto._(
          temperature: temperature,
          temperatureUnit: BuiltValueNullFieldError.checkNotNull(
              temperatureUnit, r'WeatherCurrentDataDto', 'temperatureUnit'),
          weatherCode: weatherCode,
          isDay: BuiltValueNullFieldError.checkNotNull(
              isDay, r'WeatherCurrentDataDto', 'isDay'),
          observedAt: observedAt,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
