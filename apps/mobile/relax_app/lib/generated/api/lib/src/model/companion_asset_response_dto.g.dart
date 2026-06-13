// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companion_asset_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CompanionAssetResponseDto extends CompanionAssetResponseDto {
  @override
  final String id;
  @override
  final String name;
  @override
  final JsonObject type;
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
  final String? zodiacSign;
  @override
  final String? chineseZodiac;
  @override
  final bool isDefault;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$CompanionAssetResponseDto(
          [void Function(CompanionAssetResponseDtoBuilder)? updates]) =>
      (CompanionAssetResponseDtoBuilder()..update(updates))._build();

  _$CompanionAssetResponseDto._(
      {required this.id,
      required this.name,
      required this.type,
      this.description,
      this.previewImageUrl,
      this.spriteSheetUrl,
      this.idleAnimationUrl,
      this.sleepAnimationUrl,
      this.walkAnimationUrl,
      this.primaryColor,
      this.secondaryColor,
      this.accentColor,
      this.zodiacSign,
      this.chineseZodiac,
      required this.isDefault,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  CompanionAssetResponseDto rebuild(
          void Function(CompanionAssetResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CompanionAssetResponseDtoBuilder toBuilder() =>
      CompanionAssetResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompanionAssetResponseDto &&
        id == other.id &&
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
        zodiacSign == other.zodiacSign &&
        chineseZodiac == other.chineseZodiac &&
        isDefault == other.isDefault &&
        isActive == other.isActive &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
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
    _$hash = $jc(_$hash, zodiacSign.hashCode);
    _$hash = $jc(_$hash, chineseZodiac.hashCode);
    _$hash = $jc(_$hash, isDefault.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CompanionAssetResponseDto')
          ..add('id', id)
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
          ..add('zodiacSign', zodiacSign)
          ..add('chineseZodiac', chineseZodiac)
          ..add('isDefault', isDefault)
          ..add('isActive', isActive)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class CompanionAssetResponseDtoBuilder
    implements
        Builder<CompanionAssetResponseDto, CompanionAssetResponseDtoBuilder> {
  _$CompanionAssetResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

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

  String? _zodiacSign;
  String? get zodiacSign => _$this._zodiacSign;
  set zodiacSign(String? zodiacSign) => _$this._zodiacSign = zodiacSign;

  String? _chineseZodiac;
  String? get chineseZodiac => _$this._chineseZodiac;
  set chineseZodiac(String? chineseZodiac) =>
      _$this._chineseZodiac = chineseZodiac;

  bool? _isDefault;
  bool? get isDefault => _$this._isDefault;
  set isDefault(bool? isDefault) => _$this._isDefault = isDefault;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  CompanionAssetResponseDtoBuilder() {
    CompanionAssetResponseDto._defaults(this);
  }

  CompanionAssetResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
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
      _zodiacSign = $v.zodiacSign;
      _chineseZodiac = $v.chineseZodiac;
      _isDefault = $v.isDefault;
      _isActive = $v.isActive;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CompanionAssetResponseDto other) {
    _$v = other as _$CompanionAssetResponseDto;
  }

  @override
  void update(void Function(CompanionAssetResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CompanionAssetResponseDto build() => _build();

  _$CompanionAssetResponseDto _build() {
    final _$result = _$v ??
        _$CompanionAssetResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'CompanionAssetResponseDto', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'CompanionAssetResponseDto', 'name'),
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'CompanionAssetResponseDto', 'type'),
          description: description,
          previewImageUrl: previewImageUrl,
          spriteSheetUrl: spriteSheetUrl,
          idleAnimationUrl: idleAnimationUrl,
          sleepAnimationUrl: sleepAnimationUrl,
          walkAnimationUrl: walkAnimationUrl,
          primaryColor: primaryColor,
          secondaryColor: secondaryColor,
          accentColor: accentColor,
          zodiacSign: zodiacSign,
          chineseZodiac: chineseZodiac,
          isDefault: BuiltValueNullFieldError.checkNotNull(
              isDefault, r'CompanionAssetResponseDto', 'isDefault'),
          isActive: BuiltValueNullFieldError.checkNotNull(
              isActive, r'CompanionAssetResponseDto', 'isActive'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'CompanionAssetResponseDto', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'CompanionAssetResponseDto', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
