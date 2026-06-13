// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_weather_location_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateWeatherLocationDto extends UpdateWeatherLocationDto {
  @override
  final num? latitude;
  @override
  final num? longitude;
  @override
  final String? timezone;
  @override
  final String? locationName;
  @override
  final bool? weatherEnabled;
  @override
  final bool? reverseGeocode;
  @override
  final String? localityLanguage;

  factory _$UpdateWeatherLocationDto(
          [void Function(UpdateWeatherLocationDtoBuilder)? updates]) =>
      (UpdateWeatherLocationDtoBuilder()..update(updates))._build();

  _$UpdateWeatherLocationDto._(
      {this.latitude,
      this.longitude,
      this.timezone,
      this.locationName,
      this.weatherEnabled,
      this.reverseGeocode,
      this.localityLanguage})
      : super._();
  @override
  UpdateWeatherLocationDto rebuild(
          void Function(UpdateWeatherLocationDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateWeatherLocationDtoBuilder toBuilder() =>
      UpdateWeatherLocationDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateWeatherLocationDto &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        timezone == other.timezone &&
        locationName == other.locationName &&
        weatherEnabled == other.weatherEnabled &&
        reverseGeocode == other.reverseGeocode &&
        localityLanguage == other.localityLanguage;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, locationName.hashCode);
    _$hash = $jc(_$hash, weatherEnabled.hashCode);
    _$hash = $jc(_$hash, reverseGeocode.hashCode);
    _$hash = $jc(_$hash, localityLanguage.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateWeatherLocationDto')
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('timezone', timezone)
          ..add('locationName', locationName)
          ..add('weatherEnabled', weatherEnabled)
          ..add('reverseGeocode', reverseGeocode)
          ..add('localityLanguage', localityLanguage))
        .toString();
  }
}

class UpdateWeatherLocationDtoBuilder
    implements
        Builder<UpdateWeatherLocationDto, UpdateWeatherLocationDtoBuilder> {
  _$UpdateWeatherLocationDto? _$v;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  String? _locationName;
  String? get locationName => _$this._locationName;
  set locationName(String? locationName) => _$this._locationName = locationName;

  bool? _weatherEnabled;
  bool? get weatherEnabled => _$this._weatherEnabled;
  set weatherEnabled(bool? weatherEnabled) =>
      _$this._weatherEnabled = weatherEnabled;

  bool? _reverseGeocode;
  bool? get reverseGeocode => _$this._reverseGeocode;
  set reverseGeocode(bool? reverseGeocode) =>
      _$this._reverseGeocode = reverseGeocode;

  String? _localityLanguage;
  String? get localityLanguage => _$this._localityLanguage;
  set localityLanguage(String? localityLanguage) =>
      _$this._localityLanguage = localityLanguage;

  UpdateWeatherLocationDtoBuilder() {
    UpdateWeatherLocationDto._defaults(this);
  }

  UpdateWeatherLocationDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _timezone = $v.timezone;
      _locationName = $v.locationName;
      _weatherEnabled = $v.weatherEnabled;
      _reverseGeocode = $v.reverseGeocode;
      _localityLanguage = $v.localityLanguage;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateWeatherLocationDto other) {
    _$v = other as _$UpdateWeatherLocationDto;
  }

  @override
  void update(void Function(UpdateWeatherLocationDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateWeatherLocationDto build() => _build();

  _$UpdateWeatherLocationDto _build() {
    final _$result = _$v ??
        _$UpdateWeatherLocationDto._(
          latitude: latitude,
          longitude: longitude,
          timezone: timezone,
          locationName: locationName,
          weatherEnabled: weatherEnabled,
          reverseGeocode: reverseGeocode,
          localityLanguage: localityLanguage,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
