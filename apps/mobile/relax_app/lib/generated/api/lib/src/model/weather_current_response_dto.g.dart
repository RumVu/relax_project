// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_current_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WeatherCurrentResponseDto extends WeatherCurrentResponseDto {
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

  factory _$WeatherCurrentResponseDto(
          [void Function(WeatherCurrentResponseDtoBuilder)? updates]) =>
      (WeatherCurrentResponseDtoBuilder()..update(updates))._build();

  _$WeatherCurrentResponseDto._(
      {required this.configured,
      this.reason,
      this.greeting,
      this.provider,
      this.location,
      this.reverseGeocode,
      this.current})
      : super._();
  @override
  WeatherCurrentResponseDto rebuild(
          void Function(WeatherCurrentResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WeatherCurrentResponseDtoBuilder toBuilder() =>
      WeatherCurrentResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WeatherCurrentResponseDto &&
        configured == other.configured &&
        reason == other.reason &&
        greeting == other.greeting &&
        provider == other.provider &&
        location == other.location &&
        reverseGeocode == other.reverseGeocode &&
        current == other.current;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WeatherCurrentResponseDto')
          ..add('configured', configured)
          ..add('reason', reason)
          ..add('greeting', greeting)
          ..add('provider', provider)
          ..add('location', location)
          ..add('reverseGeocode', reverseGeocode)
          ..add('current', current))
        .toString();
  }
}

class WeatherCurrentResponseDtoBuilder
    implements
        Builder<WeatherCurrentResponseDto, WeatherCurrentResponseDtoBuilder> {
  _$WeatherCurrentResponseDto? _$v;

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

  WeatherCurrentResponseDtoBuilder() {
    WeatherCurrentResponseDto._defaults(this);
  }

  WeatherCurrentResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _configured = $v.configured;
      _reason = $v.reason;
      _greeting = $v.greeting?.toBuilder();
      _provider = $v.provider;
      _location = $v.location?.toBuilder();
      _reverseGeocode = $v.reverseGeocode;
      _current = $v.current?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WeatherCurrentResponseDto other) {
    _$v = other as _$WeatherCurrentResponseDto;
  }

  @override
  void update(void Function(WeatherCurrentResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WeatherCurrentResponseDto build() => _build();

  _$WeatherCurrentResponseDto _build() {
    _$WeatherCurrentResponseDto _$result;
    try {
      _$result = _$v ??
          _$WeatherCurrentResponseDto._(
            configured: BuiltValueNullFieldError.checkNotNull(
                configured, r'WeatherCurrentResponseDto', 'configured'),
            reason: reason,
            greeting: _greeting?.build(),
            provider: provider,
            location: _location?.build(),
            reverseGeocode: reverseGeocode,
            current: _current?.build(),
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
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'WeatherCurrentResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
