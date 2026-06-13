// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_forecast_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WeatherForecastResponseDto extends WeatherForecastResponseDto {
  @override
  final bool configured;
  @override
  final String? reason;
  @override
  final WeatherGreetingDto? greeting;
  @override
  final String? provider;
  @override
  final WeatherLocationDto? location;
  @override
  final JsonObject? reverseGeocode;
  @override
  final WeatherCurrentDataDto? current;
  @override
  final BuiltList<WeatherForecastDayDto> forecast;

  factory _$WeatherForecastResponseDto(
          [void Function(WeatherForecastResponseDtoBuilder)? updates]) =>
      (WeatherForecastResponseDtoBuilder()..update(updates))._build();

  _$WeatherForecastResponseDto._(
      {required this.configured,
      this.reason,
      this.greeting,
      this.provider,
      this.location,
      this.reverseGeocode,
      this.current,
      required this.forecast})
      : super._();
  @override
  WeatherForecastResponseDto rebuild(
          void Function(WeatherForecastResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WeatherForecastResponseDtoBuilder toBuilder() =>
      WeatherForecastResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WeatherForecastResponseDto &&
        configured == other.configured &&
        reason == other.reason &&
        greeting == other.greeting &&
        provider == other.provider &&
        location == other.location &&
        reverseGeocode == other.reverseGeocode &&
        current == other.current &&
        forecast == other.forecast;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, configured.hashCode);
    _$hash = $jc(_$hash, reason.hashCode);
    _$hash = $jc(_$hash, greeting.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, reverseGeocode.hashCode);
    _$hash = $jc(_$hash, current.hashCode);
    _$hash = $jc(_$hash, forecast.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WeatherForecastResponseDto')
          ..add('configured', configured)
          ..add('reason', reason)
          ..add('greeting', greeting)
          ..add('provider', provider)
          ..add('location', location)
          ..add('reverseGeocode', reverseGeocode)
          ..add('current', current)
          ..add('forecast', forecast))
        .toString();
  }
}

class WeatherForecastResponseDtoBuilder
    implements
        Builder<WeatherForecastResponseDto, WeatherForecastResponseDtoBuilder> {
  _$WeatherForecastResponseDto? _$v;

  bool? _configured;
  bool? get configured => _$this._configured;
  set configured(bool? configured) => _$this._configured = configured;

  String? _reason;
  String? get reason => _$this._reason;
  set reason(String? reason) => _$this._reason = reason;

  WeatherGreetingDtoBuilder? _greeting;
  WeatherGreetingDtoBuilder get greeting =>
      _$this._greeting ??= WeatherGreetingDtoBuilder();
  set greeting(WeatherGreetingDtoBuilder? greeting) =>
      _$this._greeting = greeting;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  WeatherLocationDtoBuilder? _location;
  WeatherLocationDtoBuilder get location =>
      _$this._location ??= WeatherLocationDtoBuilder();
  set location(WeatherLocationDtoBuilder? location) =>
      _$this._location = location;

  JsonObject? _reverseGeocode;
  JsonObject? get reverseGeocode => _$this._reverseGeocode;
  set reverseGeocode(JsonObject? reverseGeocode) =>
      _$this._reverseGeocode = reverseGeocode;

  WeatherCurrentDataDtoBuilder? _current;
  WeatherCurrentDataDtoBuilder get current =>
      _$this._current ??= WeatherCurrentDataDtoBuilder();
  set current(WeatherCurrentDataDtoBuilder? current) =>
      _$this._current = current;

  ListBuilder<WeatherForecastDayDto>? _forecast;
  ListBuilder<WeatherForecastDayDto> get forecast =>
      _$this._forecast ??= ListBuilder<WeatherForecastDayDto>();
  set forecast(ListBuilder<WeatherForecastDayDto>? forecast) =>
      _$this._forecast = forecast;

  WeatherForecastResponseDtoBuilder() {
    WeatherForecastResponseDto._defaults(this);
  }

  WeatherForecastResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _configured = $v.configured;
      _reason = $v.reason;
      _greeting = $v.greeting?.toBuilder();
      _provider = $v.provider;
      _location = $v.location?.toBuilder();
      _reverseGeocode = $v.reverseGeocode;
      _current = $v.current?.toBuilder();
      _forecast = $v.forecast.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WeatherForecastResponseDto other) {
    _$v = other as _$WeatherForecastResponseDto;
  }

  @override
  void update(void Function(WeatherForecastResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WeatherForecastResponseDto build() => _build();

  _$WeatherForecastResponseDto _build() {
    _$WeatherForecastResponseDto _$result;
    try {
      _$result = _$v ??
          _$WeatherForecastResponseDto._(
            configured: BuiltValueNullFieldError.checkNotNull(
                configured, r'WeatherForecastResponseDto', 'configured'),
            reason: reason,
            greeting: _greeting?.build(),
            provider: provider,
            location: _location?.build(),
            reverseGeocode: reverseGeocode,
            current: _current?.build(),
            forecast: forecast.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'greeting';
        _greeting?.build();

        _$failedField = 'location';
        _location?.build();

        _$failedField = 'current';
        _current?.build();
        _$failedField = 'forecast';
        forecast.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WeatherForecastResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
