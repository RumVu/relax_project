// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upsert_user_preference_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpsertUserPreferenceDto extends UpsertUserPreferenceDto {
  @override
  final String? language;
  @override
  final String? timezone;
  @override
  final num? latitude;
  @override
  final num? longitude;
  @override
  final String? locationName;
  @override
  final bool? weatherEnabled;
  @override
  final JsonObject? themeMode;
  @override
  final String? themeId;
  @override
  final bool? enableCompanionBubble;
  @override
  final num? bubbleIntervalSeconds;
  @override
  final bool? enableSound;
  @override
  final bool? enableHaptics;
  @override
  final bool? pushNotificationsEnabled;
  @override
  final bool? emailNotificationsEnabled;

  factory _$UpsertUserPreferenceDto(
          [void Function(UpsertUserPreferenceDtoBuilder)? updates]) =>
      (UpsertUserPreferenceDtoBuilder()..update(updates))._build();

  _$UpsertUserPreferenceDto._(
      {this.language,
      this.timezone,
      this.latitude,
      this.longitude,
      this.locationName,
      this.weatherEnabled,
      this.themeMode,
      this.themeId,
      this.enableCompanionBubble,
      this.bubbleIntervalSeconds,
      this.enableSound,
      this.enableHaptics,
      this.pushNotificationsEnabled,
      this.emailNotificationsEnabled})
      : super._();
  @override
  UpsertUserPreferenceDto rebuild(
          void Function(UpsertUserPreferenceDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpsertUserPreferenceDtoBuilder toBuilder() =>
      UpsertUserPreferenceDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpsertUserPreferenceDto &&
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
        emailNotificationsEnabled == other.emailNotificationsEnabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpsertUserPreferenceDto')
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
          ..add('emailNotificationsEnabled', emailNotificationsEnabled))
        .toString();
  }
}

class UpsertUserPreferenceDtoBuilder
    implements
        Builder<UpsertUserPreferenceDto, UpsertUserPreferenceDtoBuilder> {
  _$UpsertUserPreferenceDto? _$v;

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

  UpsertUserPreferenceDtoBuilder() {
    UpsertUserPreferenceDto._defaults(this);
  }

  UpsertUserPreferenceDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
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
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpsertUserPreferenceDto other) {
    _$v = other as _$UpsertUserPreferenceDto;
  }

  @override
  void update(void Function(UpsertUserPreferenceDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpsertUserPreferenceDto build() => _build();

  _$UpsertUserPreferenceDto _build() {
    final _$result = _$v ??
        _$UpsertUserPreferenceDto._(
          language: language,
          timezone: timezone,
          latitude: latitude,
          longitude: longitude,
          locationName: locationName,
          weatherEnabled: weatherEnabled,
          themeMode: themeMode,
          themeId: themeId,
          enableCompanionBubble: enableCompanionBubble,
          bubbleIntervalSeconds: bubbleIntervalSeconds,
          enableSound: enableSound,
          enableHaptics: enableHaptics,
          pushNotificationsEnabled: pushNotificationsEnabled,
          emailNotificationsEnabled: emailNotificationsEnabled,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
