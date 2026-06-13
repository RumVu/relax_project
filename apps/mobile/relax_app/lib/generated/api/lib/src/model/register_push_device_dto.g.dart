// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_push_device_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RegisterPushDeviceDto extends RegisterPushDeviceDto {
  @override
  final String token;
  @override
  final JsonObject platform;
  @override
  final JsonObject? provider;
  @override
  final String? deviceId;
  @override
  final String? deviceName;
  @override
  final String? appVersion;
  @override
  final String? timezone;
  @override
  final bool? enabled;

  factory _$RegisterPushDeviceDto(
          [void Function(RegisterPushDeviceDtoBuilder)? updates]) =>
      (RegisterPushDeviceDtoBuilder()..update(updates))._build();

  _$RegisterPushDeviceDto._(
      {required this.token,
      required this.platform,
      this.provider,
      this.deviceId,
      this.deviceName,
      this.appVersion,
      this.timezone,
      this.enabled})
      : super._();
  @override
  RegisterPushDeviceDto rebuild(
          void Function(RegisterPushDeviceDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RegisterPushDeviceDtoBuilder toBuilder() =>
      RegisterPushDeviceDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RegisterPushDeviceDto &&
        token == other.token &&
        platform == other.platform &&
        provider == other.provider &&
        deviceId == other.deviceId &&
        deviceName == other.deviceName &&
        appVersion == other.appVersion &&
        timezone == other.timezone &&
        enabled == other.enabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, deviceName.hashCode);
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RegisterPushDeviceDto')
          ..add('token', token)
          ..add('platform', platform)
          ..add('provider', provider)
          ..add('deviceId', deviceId)
          ..add('deviceName', deviceName)
          ..add('appVersion', appVersion)
          ..add('timezone', timezone)
          ..add('enabled', enabled))
        .toString();
  }
}

class RegisterPushDeviceDtoBuilder
    implements Builder<RegisterPushDeviceDto, RegisterPushDeviceDtoBuilder> {
  _$RegisterPushDeviceDto? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  JsonObject? _platform;
  JsonObject? get platform => _$this._platform;
  set platform(JsonObject? platform) => _$this._platform = platform;

  JsonObject? _provider;
  JsonObject? get provider => _$this._provider;
  set provider(JsonObject? provider) => _$this._provider = provider;

  String? _deviceId;
  String? get deviceId => _$this._deviceId;
  set deviceId(String? deviceId) => _$this._deviceId = deviceId;

  String? _deviceName;
  String? get deviceName => _$this._deviceName;
  set deviceName(String? deviceName) => _$this._deviceName = deviceName;

  String? _appVersion;
  String? get appVersion => _$this._appVersion;
  set appVersion(String? appVersion) => _$this._appVersion = appVersion;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  RegisterPushDeviceDtoBuilder() {
    RegisterPushDeviceDto._defaults(this);
  }

  RegisterPushDeviceDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _platform = $v.platform;
      _provider = $v.provider;
      _deviceId = $v.deviceId;
      _deviceName = $v.deviceName;
      _appVersion = $v.appVersion;
      _timezone = $v.timezone;
      _enabled = $v.enabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RegisterPushDeviceDto other) {
    _$v = other as _$RegisterPushDeviceDto;
  }

  @override
  void update(void Function(RegisterPushDeviceDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RegisterPushDeviceDto build() => _build();

  _$RegisterPushDeviceDto _build() {
    final _$result = _$v ??
        _$RegisterPushDeviceDto._(
          token: BuiltValueNullFieldError.checkNotNull(
              token, r'RegisterPushDeviceDto', 'token'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'RegisterPushDeviceDto', 'platform'),
          provider: provider,
          deviceId: deviceId,
          deviceName: deviceName,
          appVersion: appVersion,
          timezone: timezone,
          enabled: enabled,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
