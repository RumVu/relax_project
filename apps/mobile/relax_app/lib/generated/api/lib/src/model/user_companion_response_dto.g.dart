// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_companion_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserCompanionResponseDto extends UserCompanionResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final String? assetId;
  @override
  final String name;
  @override
  final JsonObject type;
  @override
  final JsonObject personalizationMode;
  @override
  final JsonObject mood;
  @override
  final JsonObject action;
  @override
  final num level;
  @override
  final num affection;
  @override
  final num energy;
  @override
  final DateTime? lastSeenAt;
  @override
  final DateTime? lastFedAt;
  @override
  final DateTime? lastMoodAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final CompanionAssetResponseDto? asset;

  factory _$UserCompanionResponseDto(
          [void Function(UserCompanionResponseDtoBuilder)? updates]) =>
      (UserCompanionResponseDtoBuilder()..update(updates))._build();

  _$UserCompanionResponseDto._(
      {required this.id,
      required this.userId,
      this.assetId,
      required this.name,
      required this.type,
      required this.personalizationMode,
      required this.mood,
      required this.action,
      required this.level,
      required this.affection,
      required this.energy,
      this.lastSeenAt,
      this.lastFedAt,
      this.lastMoodAt,
      required this.createdAt,
      required this.updatedAt,
      this.asset})
      : super._();
  @override
  UserCompanionResponseDto rebuild(
          void Function(UserCompanionResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserCompanionResponseDtoBuilder toBuilder() =>
      UserCompanionResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserCompanionResponseDto &&
        id == other.id &&
        userId == other.userId &&
        assetId == other.assetId &&
        name == other.name &&
        type == other.type &&
        personalizationMode == other.personalizationMode &&
        mood == other.mood &&
        action == other.action &&
        level == other.level &&
        affection == other.affection &&
        energy == other.energy &&
        lastSeenAt == other.lastSeenAt &&
        lastFedAt == other.lastFedAt &&
        lastMoodAt == other.lastMoodAt &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        asset == other.asset;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, assetId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, personalizationMode.hashCode);
    _$hash = $jc(_$hash, mood.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, level.hashCode);
    _$hash = $jc(_$hash, affection.hashCode);
    _$hash = $jc(_$hash, energy.hashCode);
    _$hash = $jc(_$hash, lastSeenAt.hashCode);
    _$hash = $jc(_$hash, lastFedAt.hashCode);
    _$hash = $jc(_$hash, lastMoodAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, asset.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserCompanionResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('assetId', assetId)
          ..add('name', name)
          ..add('type', type)
          ..add('personalizationMode', personalizationMode)
          ..add('mood', mood)
          ..add('action', action)
          ..add('level', level)
          ..add('affection', affection)
          ..add('energy', energy)
          ..add('lastSeenAt', lastSeenAt)
          ..add('lastFedAt', lastFedAt)
          ..add('lastMoodAt', lastMoodAt)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('asset', asset))
        .toString();
  }
}

class UserCompanionResponseDtoBuilder
    implements
        Builder<UserCompanionResponseDto, UserCompanionResponseDtoBuilder> {
  _$UserCompanionResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _assetId;
  String? get assetId => _$this._assetId;
  set assetId(String? assetId) => _$this._assetId = assetId;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  JsonObject? _type;
  JsonObject? get type => _$this._type;
  set type(JsonObject? type) => _$this._type = type;

  JsonObject? _personalizationMode;
  JsonObject? get personalizationMode => _$this._personalizationMode;
  set personalizationMode(JsonObject? personalizationMode) =>
      _$this._personalizationMode = personalizationMode;

  JsonObject? _mood;
  JsonObject? get mood => _$this._mood;
  set mood(JsonObject? mood) => _$this._mood = mood;

  JsonObject? _action;
  JsonObject? get action => _$this._action;
  set action(JsonObject? action) => _$this._action = action;

  num? _level;
  num? get level => _$this._level;
  set level(num? level) => _$this._level = level;

  num? _affection;
  num? get affection => _$this._affection;
  set affection(num? affection) => _$this._affection = affection;

  num? _energy;
  num? get energy => _$this._energy;
  set energy(num? energy) => _$this._energy = energy;

  DateTime? _lastSeenAt;
  DateTime? get lastSeenAt => _$this._lastSeenAt;
  set lastSeenAt(DateTime? lastSeenAt) => _$this._lastSeenAt = lastSeenAt;

  DateTime? _lastFedAt;
  DateTime? get lastFedAt => _$this._lastFedAt;
  set lastFedAt(DateTime? lastFedAt) => _$this._lastFedAt = lastFedAt;

  DateTime? _lastMoodAt;
  DateTime? get lastMoodAt => _$this._lastMoodAt;
  set lastMoodAt(DateTime? lastMoodAt) => _$this._lastMoodAt = lastMoodAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  CompanionAssetResponseDtoBuilder? _asset;
  CompanionAssetResponseDtoBuilder get asset =>
      _$this._asset ??= CompanionAssetResponseDtoBuilder();
  set asset(CompanionAssetResponseDtoBuilder? asset) => _$this._asset = asset;

  UserCompanionResponseDtoBuilder() {
    UserCompanionResponseDto._defaults(this);
  }

  UserCompanionResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _assetId = $v.assetId;
      _name = $v.name;
      _type = $v.type;
      _personalizationMode = $v.personalizationMode;
      _mood = $v.mood;
      _action = $v.action;
      _level = $v.level;
      _affection = $v.affection;
      _energy = $v.energy;
      _lastSeenAt = $v.lastSeenAt;
      _lastFedAt = $v.lastFedAt;
      _lastMoodAt = $v.lastMoodAt;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _asset = $v.asset?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserCompanionResponseDto other) {
    _$v = other as _$UserCompanionResponseDto;
  }

  @override
  void update(void Function(UserCompanionResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserCompanionResponseDto build() => _build();

  _$UserCompanionResponseDto _build() {
    _$UserCompanionResponseDto _$result;
    try {
      _$result = _$v ??
          _$UserCompanionResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'UserCompanionResponseDto', 'id'),
            userId: BuiltValueNullFieldError.checkNotNull(
                userId, r'UserCompanionResponseDto', 'userId'),
            assetId: assetId,
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'UserCompanionResponseDto', 'name'),
            type: BuiltValueNullFieldError.checkNotNull(
                type, r'UserCompanionResponseDto', 'type'),
            personalizationMode: BuiltValueNullFieldError.checkNotNull(
                personalizationMode,
                r'UserCompanionResponseDto',
                'personalizationMode'),
            mood: BuiltValueNullFieldError.checkNotNull(
                mood, r'UserCompanionResponseDto', 'mood'),
            action: BuiltValueNullFieldError.checkNotNull(
                action, r'UserCompanionResponseDto', 'action'),
            level: BuiltValueNullFieldError.checkNotNull(
                level, r'UserCompanionResponseDto', 'level'),
            affection: BuiltValueNullFieldError.checkNotNull(
                affection, r'UserCompanionResponseDto', 'affection'),
            energy: BuiltValueNullFieldError.checkNotNull(
                energy, r'UserCompanionResponseDto', 'energy'),
            lastSeenAt: lastSeenAt,
            lastFedAt: lastFedAt,
            lastMoodAt: lastMoodAt,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'UserCompanionResponseDto', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'UserCompanionResponseDto', 'updatedAt'),
            asset: _asset?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'asset';
        _asset?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UserCompanionResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
