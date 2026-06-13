// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'push_device_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PushDeviceResponseDto extends PushDeviceResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final String token;
  @override
  final JsonObject platform;
  @override
  final JsonObject provider;
  @override
  final String? deviceId;
  @override
  final String? deviceName;
  @override
  final String? appVersion;
  @override
  final String? timezone;
  @override
  final bool enabled;
  @override
  final DateTime lastSeenAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$PushDeviceResponseDto(
          [void Function(PushDeviceResponseDtoBuilder)? updates]) =>
      (PushDeviceResponseDtoBuilder()..update(updates))._build();

  _$PushDeviceResponseDto._(
      {required this.id,
      required this.userId,
      required this.token,
      required this.platform,
      required this.provider,
      this.deviceId,
      this.deviceName,
      this.appVersion,
      this.timezone,
      required this.enabled,
      required this.lastSeenAt,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  PushDeviceResponseDto rebuild(
          void Function(PushDeviceResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PushDeviceResponseDtoBuilder toBuilder() =>
      PushDeviceResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PushDeviceResponseDto &&
        id == other.id &&
        userId == other.userId &&
        token == other.token &&
        platform == other.platform &&
        provider == other.provider &&
        deviceId == other.deviceId &&
        deviceName == other.deviceName &&
        appVersion == other.appVersion &&
        timezone == other.timezone &&
        enabled == other.enabled &&
        lastSeenAt == other.lastSeenAt &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jc(_$hash, platform.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, deviceId.hashCode);
    _$hash = $jc(_$hash, deviceName.hashCode);
    _$hash = $jc(_$hash, appVersion.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jc(_$hash, lastSeenAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PushDeviceResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('token', token)
          ..add('platform', platform)
          ..add('provider', provider)
          ..add('deviceId', deviceId)
          ..add('deviceName', deviceName)
          ..add('appVersion', appVersion)
          ..add('timezone', timezone)
          ..add('enabled', enabled)
          ..add('lastSeenAt', lastSeenAt)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class PushDeviceResponseDtoBuilder
    implements Builder<PushDeviceResponseDto, PushDeviceResponseDtoBuilder> {
  _$PushDeviceResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

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

  DateTime? _lastSeenAt;
  DateTime? get lastSeenAt => _$this._lastSeenAt;
  set lastSeenAt(DateTime? lastSeenAt) => _$this._lastSeenAt = lastSeenAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PushDeviceResponseDtoBuilder() {
    PushDeviceResponseDto._defaults(this);
  }

  PushDeviceResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _token = $v.token;
      _platform = $v.platform;
      _provider = $v.provider;
      _deviceId = $v.deviceId;
      _deviceName = $v.deviceName;
      _appVersion = $v.appVersion;
      _timezone = $v.timezone;
      _enabled = $v.enabled;
      _lastSeenAt = $v.lastSeenAt;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PushDeviceResponseDto other) {
    _$v = other as _$PushDeviceResponseDto;
  }

  @override
  void update(void Function(PushDeviceResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PushDeviceResponseDto build() => _build();

  _$PushDeviceResponseDto _build() {
    final _$result = _$v ??
        _$PushDeviceResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'PushDeviceResponseDto', 'id'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'PushDeviceResponseDto', 'userId'),
          token: BuiltValueNullFieldError.checkNotNull(
              token, r'PushDeviceResponseDto', 'token'),
          platform: BuiltValueNullFieldError.checkNotNull(
              platform, r'PushDeviceResponseDto', 'platform'),
          provider: BuiltValueNullFieldError.checkNotNull(
              provider, r'PushDeviceResponseDto', 'provider'),
          deviceId: deviceId,
          deviceName: deviceName,
          appVersion: appVersion,
          timezone: timezone,
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'PushDeviceResponseDto', 'enabled'),
          lastSeenAt: BuiltValueNullFieldError.checkNotNull(
              lastSeenAt, r'PushDeviceResponseDto', 'lastSeenAt'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'PushDeviceResponseDto', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'PushDeviceResponseDto', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
