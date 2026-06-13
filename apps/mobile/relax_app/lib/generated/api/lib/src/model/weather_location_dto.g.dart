// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_location_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WeatherLocationDto extends WeatherLocationDto {
  @override
  final num latitude;
  @override
  final num longitude;
  @override
  final String? name;
  @override
  final String timezone;

  factory _$WeatherLocationDto(
          [void Function(WeatherLocationDtoBuilder)? updates]) =>
      (WeatherLocationDtoBuilder()..update(updates))._build();

  _$WeatherLocationDto._(
      {required this.latitude,
      required this.longitude,
      this.name,
      required this.timezone})
      : super._();
  @override
  WeatherLocationDto rebuild(
          void Function(WeatherLocationDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WeatherLocationDtoBuilder toBuilder() =>
      WeatherLocationDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WeatherLocationDto &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        name == other.name &&
        timezone == other.timezone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WeatherLocationDto')
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('name', name)
          ..add('timezone', timezone))
        .toString();
  }
}

class WeatherLocationDtoBuilder
    implements Builder<WeatherLocationDto, WeatherLocationDtoBuilder> {
  _$WeatherLocationDto? _$v;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  WeatherLocationDtoBuilder() {
    WeatherLocationDto._defaults(this);
  }

  WeatherLocationDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _name = $v.name;
      _timezone = $v.timezone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WeatherLocationDto other) {
    _$v = other as _$WeatherLocationDto;
  }

  @override
  void update(void Function(WeatherLocationDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WeatherLocationDto build() => _build();

  _$WeatherLocationDto _build() {
    final _$result = _$v ??
        _$WeatherLocationDto._(
          latitude: BuiltValueNullFieldError.checkNotNull(
              latitude, r'WeatherLocationDto', 'latitude'),
          longitude: BuiltValueNullFieldError.checkNotNull(
              longitude, r'WeatherLocationDto', 'longitude'),
          name: name,
          timezone: BuiltValueNullFieldError.checkNotNull(
              timezone, r'WeatherLocationDto', 'timezone'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
