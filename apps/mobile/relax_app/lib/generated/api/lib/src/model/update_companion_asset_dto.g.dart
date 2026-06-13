// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_companion_asset_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateCompanionAssetDto extends UpdateCompanionAssetDto {
  @override
  final String? name;
  @override
  final JsonObject? type;
  @override
  final String? description;
  @override
  final String? previewImageUrl;
  @override
  final String? spriteSheetUrl;
  @override
  final String? idleAnimationUrl;
  @override
  final String? sleepAnimationUrl;
  @override
  final String? walkAnimationUrl;
  @override
  final String? primaryColor;
  @override
  final String? secondaryColor;
  @override
  final String? accentColor;
  @override
  final bool? isDefault;
  @override
  final bool? isActive;

  factory _$UpdateCompanionAssetDto(
          [void Function(UpdateCompanionAssetDtoBuilder)? updates]) =>
      (UpdateCompanionAssetDtoBuilder()..update(updates))._build();

  _$UpdateCompanionAssetDto._(
      {this.name,
      this.type,
      this.description,
      this.previewImageUrl,
      this.spriteSheetUrl,
      this.idleAnimationUrl,
      this.sleepAnimationUrl,
      this.walkAnimationUrl,
      this.primaryColor,
      this.secondaryColor,
      this.accentColor,
      this.isDefault,
      this.isActive})
      : super._();
  @override
  UpdateCompanionAssetDto rebuild(
          void Function(UpdateCompanionAssetDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateCompanionAssetDtoBuilder toBuilder() =>
      UpdateCompanionAssetDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateCompanionAssetDto &&
        name == other.name &&
        type == other.type &&
        description == other.description &&
        previewImageUrl == other.previewImageUrl &&
        spriteSheetUrl == other.spriteSheetUrl &&
        idleAnimationUrl == other.idleAnimationUrl &&
        sleepAnimationUrl == other.sleepAnimationUrl &&
        walkAnimationUrl == other.walkAnimationUrl &&
        primaryColor == other.primaryColor &&
        secondaryColor == other.secondaryColor &&
        accentColor == other.accentColor &&
        isDefault == other.isDefault &&
        isActive == other.isActive;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, previewImageUrl.hashCode);
    _$hash = $jc(_$hash, spriteSheetUrl.hashCode);
    _$hash = $jc(_$hash, idleAnimationUrl.hashCode);
    _$hash = $jc(_$hash, sleepAnimationUrl.hashCode);
    _$hash = $jc(_$hash, walkAnimationUrl.hashCode);
    _$hash = $jc(_$hash, primaryColor.hashCode);
    _$hash = $jc(_$hash, secondaryColor.hashCode);
    _$hash = $jc(_$hash, accentColor.hashCode);
    _$hash = $jc(_$hash, isDefault.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateCompanionAssetDto')
          ..add('name', name)
          ..add('type', type)
          ..add('description', description)
          ..add('previewImageUrl', previewImageUrl)
          ..add('spriteSheetUrl', spriteSheetUrl)
          ..add('idleAnimationUrl', idleAnimationUrl)
          ..add('sleepAnimationUrl', sleepAnimationUrl)
          ..add('walkAnimationUrl', walkAnimationUrl)
          ..add('primaryColor', primaryColor)
          ..add('secondaryColor', secondaryColor)
          ..add('accentColor', accentColor)
          ..add('isDefault', isDefault)
          ..add('isActive', isActive))
        .toString();
  }
}

class UpdateCompanionAssetDtoBuilder
    implements
        Builder<UpdateCompanionAssetDto, UpdateCompanionAssetDtoBuilder> {
  _$UpdateCompanionAssetDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  JsonObject? _type;
  JsonObject? get type => _$this._type;
  set type(JsonObject? type) => _$this._type = type;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _previewImageUrl;
  String? get previewImageUrl => _$this._previewImageUrl;
  set previewImageUrl(String? previewImageUrl) =>
      _$this._previewImageUrl = previewImageUrl;

  String? _spriteSheetUrl;
  String? get spriteSheetUrl => _$this._spriteSheetUrl;
  set spriteSheetUrl(String? spriteSheetUrl) =>
      _$this._spriteSheetUrl = spriteSheetUrl;

  String? _idleAnimationUrl;
  String? get idleAnimationUrl => _$this._idleAnimationUrl;
  set idleAnimationUrl(String? idleAnimationUrl) =>
      _$this._idleAnimationUrl = idleAnimationUrl;

  String? _sleepAnimationUrl;
  String? get sleepAnimationUrl => _$this._sleepAnimationUrl;
  set sleepAnimationUrl(String? sleepAnimationUrl) =>
      _$this._sleepAnimationUrl = sleepAnimationUrl;

  String? _walkAnimationUrl;
  String? get walkAnimationUrl => _$this._walkAnimationUrl;
  set walkAnimationUrl(String? walkAnimationUrl) =>
      _$this._walkAnimationUrl = walkAnimationUrl;

  String? _primaryColor;
  String? get primaryColor => _$this._primaryColor;
  set primaryColor(String? primaryColor) => _$this._primaryColor = primaryColor;

  String? _secondaryColor;
  String? get secondaryColor => _$this._secondaryColor;
  set secondaryColor(String? secondaryColor) =>
      _$this._secondaryColor = secondaryColor;

  String? _accentColor;
  String? get accentColor => _$this._accentColor;
  set accentColor(String? accentColor) => _$this._accentColor = accentColor;

  bool? _isDefault;
  bool? get isDefault => _$this._isDefault;
  set isDefault(bool? isDefault) => _$this._isDefault = isDefault;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  UpdateCompanionAssetDtoBuilder() {
    UpdateCompanionAssetDto._defaults(this);
  }

  UpdateCompanionAssetDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _type = $v.type;
      _description = $v.description;
      _previewImageUrl = $v.previewImageUrl;
      _spriteSheetUrl = $v.spriteSheetUrl;
      _idleAnimationUrl = $v.idleAnimationUrl;
      _sleepAnimationUrl = $v.sleepAnimationUrl;
      _walkAnimationUrl = $v.walkAnimationUrl;
      _primaryColor = $v.primaryColor;
      _secondaryColor = $v.secondaryColor;
      _accentColor = $v.accentColor;
      _isDefault = $v.isDefault;
      _isActive = $v.isActive;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateCompanionAssetDto other) {
    _$v = other as _$UpdateCompanionAssetDto;
  }

  @override
  void update(void Function(UpdateCompanionAssetDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateCompanionAssetDto build() => _build();

  _$UpdateCompanionAssetDto _build() {
    final _$result = _$v ??
        _$UpdateCompanionAssetDto._(
          name: name,
          type: type,
          description: description,
          previewImageUrl: previewImageUrl,
          spriteSheetUrl: spriteSheetUrl,
          idleAnimationUrl: idleAnimationUrl,
          sleepAnimationUrl: sleepAnimationUrl,
          walkAnimationUrl: walkAnimationUrl,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          accentColor: accentColor,
          isDefault: isDefault,
          isActive: isActive,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
