// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_preference_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserPreferenceResponseDto extends UserPreferenceResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final String language;
  @override
  final String timezone;
  @override
  final num? latitude;
  @override
  final num? longitude;
  @override
  final String? locationName;
  @override
  final bool weatherEnabled;
  @override
  final JsonObject themeMode;
  @override
  final String? themeId;
  @override
  final bool enableCompanionBubble;
  @override
  final num bubbleIntervalSeconds;
  @override
  final bool enableSound;
  @override
  final bool enableHaptics;
  @override
  final bool pushNotificationsEnabled;
  @override
  final bool emailNotificationsEnabled;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$UserPreferenceResponseDto(
          [void Function(UserPreferenceResponseDtoBuilder)? updates]) =>
      (UserPreferenceResponseDtoBuilder()..update(updates))._build();

  _$UserPreferenceResponseDto._(
      {required this.id,
      required this.userId,
      required this.language,
      required this.timezone,
      this.latitude,
      this.longitude,
      this.locationName,
      required this.weatherEnabled,
      required this.themeMode,
      this.themeId,
      required this.enableCompanionBubble,
      required this.bubbleIntervalSeconds,
      required this.enableSound,
      required this.enableHaptics,
      required this.pushNotificationsEnabled,
      required this.emailNotificationsEnabled,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  UserPreferenceResponseDto rebuild(
          void Function(UserPreferenceResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserPreferenceResponseDtoBuilder toBuilder() =>
      UserPreferenceResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserPreferenceResponseDto &&
        id == other.id &&
        userId == other.userId &&
        language == other.language &&
        timezone == other.timezone &&
        latitude == other.latitude &&
        longitude == other.longitude &&
        locationName == other.locationName &&
        weatherEnabled == other.weatherEnabled &&
        themeMode == other.themeMode &&
        themeId == other.themeId &&
        enableCompanionBubble == other.enableCompanionBubble &&
        bubbleIntervalSeconds == other.bubbleIntervalSeconds &&
        enableSound == other.enableSound &&
        enableHaptics == other.enableHaptics &&
        pushNotificationsEnabled == other.pushNotificationsEnabled &&
        emailNotificationsEnabled == other.emailNotificationsEnabled &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, language.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, latitude.hashCode);
    _$hash = $jc(_$hash, longitude.hashCode);
    _$hash = $jc(_$hash, locationName.hashCode);
    _$hash = $jc(_$hash, weatherEnabled.hashCode);
    _$hash = $jc(_$hash, themeMode.hashCode);
    _$hash = $jc(_$hash, themeId.hashCode);
    _$hash = $jc(_$hash, enableCompanionBubble.hashCode);
    _$hash = $jc(_$hash, bubbleIntervalSeconds.hashCode);
    _$hash = $jc(_$hash, enableSound.hashCode);
    _$hash = $jc(_$hash, enableHaptics.hashCode);
    _$hash = $jc(_$hash, pushNotificationsEnabled.hashCode);
    _$hash = $jc(_$hash, emailNotificationsEnabled.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserPreferenceResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('language', language)
          ..add('timezone', timezone)
          ..add('latitude', latitude)
          ..add('longitude', longitude)
          ..add('locationName', locationName)
          ..add('weatherEnabled', weatherEnabled)
          ..add('themeMode', themeMode)
          ..add('themeId', themeId)
          ..add('enableCompanionBubble', enableCompanionBubble)
          ..add('bubbleIntervalSeconds', bubbleIntervalSeconds)
          ..add('enableSound', enableSound)
          ..add('enableHaptics', enableHaptics)
          ..add('pushNotificationsEnabled', pushNotificationsEnabled)
          ..add('emailNotificationsEnabled', emailNotificationsEnabled)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class UserPreferenceResponseDtoBuilder
    implements
        Builder<UserPreferenceResponseDto, UserPreferenceResponseDtoBuilder> {
  _$UserPreferenceResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _language;
  String? get language => _$this._language;
  set language(String? language) => _$this._language = language;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  num? _latitude;
  num? get latitude => _$this._latitude;
  set latitude(num? latitude) => _$this._latitude = latitude;

  num? _longitude;
  num? get longitude => _$this._longitude;
  set longitude(num? longitude) => _$this._longitude = longitude;

  String? _locationName;
  String? get locationName => _$this._locationName;
  set locationName(String? locationName) => _$this._locationName = locationName;

  bool? _weatherEnabled;
  bool? get weatherEnabled => _$this._weatherEnabled;
  set weatherEnabled(bool? weatherEnabled) =>
      _$this._weatherEnabled = weatherEnabled;

  JsonObject? _themeMode;
  JsonObject? get themeMode => _$this._themeMode;
  set themeMode(JsonObject? themeMode) => _$this._themeMode = themeMode;

  String? _themeId;
  String? get themeId => _$this._themeId;
  set themeId(String? themeId) => _$this._themeId = themeId;

  bool? _enableCompanionBubble;
  bool? get enableCompanionBubble => _$this._enableCompanionBubble;
  set enableCompanionBubble(bool? enableCompanionBubble) =>
      _$this._enableCompanionBubble = enableCompanionBubble;

  num? _bubbleIntervalSeconds;
  num? get bubbleIntervalSeconds => _$this._bubbleIntervalSeconds;
  set bubbleIntervalSeconds(num? bubbleIntervalSeconds) =>
      _$this._bubbleIntervalSeconds = bubbleIntervalSeconds;

  bool? _enableSound;
  bool? get enableSound => _$this._enableSound;
  set enableSound(bool? enableSound) => _$this._enableSound = enableSound;

  bool? _enableHaptics;
  bool? get enableHaptics => _$this._enableHaptics;
  set enableHaptics(bool? enableHaptics) =>
      _$this._enableHaptics = enableHaptics;

  bool? _pushNotificationsEnabled;
  bool? get pushNotificationsEnabled => _$this._pushNotificationsEnabled;
  set pushNotificationsEnabled(bool? pushNotificationsEnabled) =>
      _$this._pushNotificationsEnabled = pushNotificationsEnabled;

  bool? _emailNotificationsEnabled;
  bool? get emailNotificationsEnabled => _$this._emailNotificationsEnabled;
  set emailNotificationsEnabled(bool? emailNotificationsEnabled) =>
      _$this._emailNotificationsEnabled = emailNotificationsEnabled;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  UserPreferenceResponseDtoBuilder() {
    UserPreferenceResponseDto._defaults(this);
  }

  UserPreferenceResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _language = $v.language;
      _timezone = $v.timezone;
      _latitude = $v.latitude;
      _longitude = $v.longitude;
      _locationName = $v.locationName;
      _weatherEnabled = $v.weatherEnabled;
      _themeMode = $v.themeMode;
      _themeId = $v.themeId;
      _enableCompanionBubble = $v.enableCompanionBubble;
      _bubbleIntervalSeconds = $v.bubbleIntervalSeconds;
      _enableSound = $v.enableSound;
      _enableHaptics = $v.enableHaptics;
      _pushNotificationsEnabled = $v.pushNotificationsEnabled;
      _emailNotificationsEnabled = $v.emailNotificationsEnabled;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserPreferenceResponseDto other) {
    _$v = other as _$UserPreferenceResponseDto;
  }

  @override
  void update(void Function(UserPreferenceResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserPreferenceResponseDto build() => _build();

  _$UserPreferenceResponseDto _build() {
    final _$result = _$v ??
        _$UserPreferenceResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'UserPreferenceResponseDto', 'id'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'UserPreferenceResponseDto', 'userId'),
          language: BuiltValueNullFieldError.checkNotNull(
              language, r'UserPreferenceResponseDto', 'language'),
          timezone: BuiltValueNullFieldError.checkNotNull(
              timezone, r'UserPreferenceResponseDto', 'timezone'),
          latitude: latitude,
          longitude: longitude,
          locationName: locationName,
          weatherEnabled: BuiltValueNullFieldError.checkNotNull(
              weatherEnabled, r'UserPreferenceResponseDto', 'weatherEnabled'),
          themeMode: BuiltValueNullFieldError.checkNotNull(
              themeMode, r'UserPreferenceResponseDto', 'themeMode'),
          themeId: themeId,
          enableCompanionBubble: BuiltValueNullFieldError.checkNotNull(
              enableCompanionBubble,
              r'UserPreferenceResponseDto',
              'enableCompanionBubble'),
          bubbleIntervalSeconds: BuiltValueNullFieldError.checkNotNull(
              bubbleIntervalSeconds,
              r'UserPreferenceResponseDto',
              'bubbleIntervalSeconds'),
          enableSound: BuiltValueNullFieldError.checkNotNull(
              enableSound, r'UserPreferenceResponseDto', 'enableSound'),
          enableHaptics: BuiltValueNullFieldError.checkNotNull(
              enableHaptics, r'UserPreferenceResponseDto', 'enableHaptics'),
          pushNotificationsEnabled: BuiltValueNullFieldError.checkNotNull(
              pushNotificationsEnabled,
              r'UserPreferenceResponseDto',
              'pushNotificationsEnabled'),
          emailNotificationsEnabled: BuiltValueNullFieldError.checkNotNull(
              emailNotificationsEnabled,
              r'UserPreferenceResponseDto',
              'emailNotificationsEnabled'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'UserPreferenceResponseDto', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'UserPreferenceResponseDto', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
