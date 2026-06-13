// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upsert_user_companion_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpsertUserCompanionDto extends UpsertUserCompanionDto {
  @override
  final String? assetId;
  @override
  final String? name;
  @override
  final JsonObject? type;
  @override
  final JsonObject? personalizationMode;
  @override
  final JsonObject? mood;
  @override
  final JsonObject? action;
  @override
  final num? level;
  @override
  final num? affection;
  @override
  final num? energy;

  factory _$UpsertUserCompanionDto(
          [void Function(UpsertUserCompanionDtoBuilder)? updates]) =>
      (UpsertUserCompanionDtoBuilder()..update(updates))._build();

  _$UpsertUserCompanionDto._(
      {this.assetId,
      this.name,
      this.type,
      this.personalizationMode,
      this.mood,
      this.action,
      this.level,
      this.affection,
      this.energy})
      : super._();
  @override
  UpsertUserCompanionDto rebuild(
          void Function(UpsertUserCompanionDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpsertUserCompanionDtoBuilder toBuilder() =>
      UpsertUserCompanionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpsertUserCompanionDto &&
        assetId == other.assetId &&
        name == other.name &&
        type == other.type &&
        personalizationMode == other.personalizationMode &&
        mood == other.mood &&
        action == other.action &&
        level == other.level &&
        affection == other.affection &&
        energy == other.energy;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, assetId.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, personalizationMode.hashCode);
    _$hash = $jc(_$hash, mood.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, level.hashCode);
    _$hash = $jc(_$hash, affection.hashCode);
    _$hash = $jc(_$hash, energy.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpsertUserCompanionDto')
          ..add('assetId', assetId)
          ..add('name', name)
          ..add('type', type)
          ..add('personalizationMode', personalizationMode)
          ..add('mood', mood)
          ..add('action', action)
          ..add('level', level)
          ..add('affection', affection)
          ..add('energy', energy))
        .toString();
  }
}

class UpsertUserCompanionDtoBuilder
    implements Builder<UpsertUserCompanionDto, UpsertUserCompanionDtoBuilder> {
  _$UpsertUserCompanionDto? _$v;

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

  UpsertUserCompanionDtoBuilder() {
    UpsertUserCompanionDto._defaults(this);
  }

  UpsertUserCompanionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _assetId = $v.assetId;
      _name = $v.name;
      _type = $v.type;
      _personalizationMode = $v.personalizationMode;
      _mood = $v.mood;
      _action = $v.action;
      _level = $v.level;
      _affection = $v.affection;
      _energy = $v.energy;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpsertUserCompanionDto other) {
    _$v = other as _$UpsertUserCompanionDto;
  }

  @override
  void update(void Function(UpsertUserCompanionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpsertUserCompanionDto build() => _build();

  _$UpsertUserCompanionDto _build() {
    final _$result = _$v ??
        _$UpsertUserCompanionDto._(
          assetId: assetId,
          name: name,
          type: type,
          personalizationMode: personalizationMode,
          mood: mood,
          action: action,
          level: level,
          affection: affection,
          energy: energy,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
