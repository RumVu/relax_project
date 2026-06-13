// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_theme_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppThemeResponseDto extends AppThemeResponseDto {
  @override
  final String id;
  @override
  final String name;
  @override
  final JsonObject mode;
  @override
  final String backgroundColor;
  @override
  final String surfaceColor;
  @override
  final String primaryColor;
  @override
  final String? secondaryColor;
  @override
  final String? accentColor;
  @override
  final String textColor;
  @override
  final String? mutedTextColor;
  @override
  final bool isDefault;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$AppThemeResponseDto(
          [void Function(AppThemeResponseDtoBuilder)? updates]) =>
      (AppThemeResponseDtoBuilder()..update(updates))._build();

  _$AppThemeResponseDto._(
      {required this.id,
      required this.name,
      required this.mode,
      required this.backgroundColor,
      required this.surfaceColor,
      required this.primaryColor,
      this.secondaryColor,
      this.accentColor,
      required this.textColor,
      this.mutedTextColor,
      required this.isDefault,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  AppThemeResponseDto rebuild(
          void Function(AppThemeResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AppThemeResponseDtoBuilder toBuilder() =>
      AppThemeResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppThemeResponseDto &&
        id == other.id &&
        name == other.name &&
        mode == other.mode &&
        backgroundColor == other.backgroundColor &&
        surfaceColor == other.surfaceColor &&
        primaryColor == other.primaryColor &&
        secondaryColor == other.secondaryColor &&
        accentColor == other.accentColor &&
        textColor == other.textColor &&
        mutedTextColor == other.mutedTextColor &&
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
    _$hash = $jc(_$hash, mode.hashCode);
    _$hash = $jc(_$hash, backgroundColor.hashCode);
    _$hash = $jc(_$hash, surfaceColor.hashCode);
    _$hash = $jc(_$hash, primaryColor.hashCode);
    _$hash = $jc(_$hash, secondaryColor.hashCode);
    _$hash = $jc(_$hash, accentColor.hashCode);
    _$hash = $jc(_$hash, textColor.hashCode);
    _$hash = $jc(_$hash, mutedTextColor.hashCode);
    _$hash = $jc(_$hash, isDefault.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AppThemeResponseDto')
          ..add('id', id)
          ..add('name', name)
          ..add('mode', mode)
          ..add('backgroundColor', backgroundColor)
          ..add('surfaceColor', surfaceColor)
          ..add('primaryColor', primaryColor)
          ..add('secondaryColor', secondaryColor)
          ..add('accentColor', accentColor)
          ..add('textColor', textColor)
          ..add('mutedTextColor', mutedTextColor)
          ..add('isDefault', isDefault)
          ..add('isActive', isActive)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class AppThemeResponseDtoBuilder
    implements Builder<AppThemeResponseDto, AppThemeResponseDtoBuilder> {
  _$AppThemeResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  JsonObject? _mode;
  JsonObject? get mode => _$this._mode;
  set mode(JsonObject? mode) => _$this._mode = mode;

  String? _backgroundColor;
  String? get backgroundColor => _$this._backgroundColor;
  set backgroundColor(String? backgroundColor) =>
      _$this._backgroundColor = backgroundColor;

  String? _surfaceColor;
  String? get surfaceColor => _$this._surfaceColor;
  set surfaceColor(String? surfaceColor) => _$this._surfaceColor = surfaceColor;

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

  String? _textColor;
  String? get textColor => _$this._textColor;
  set textColor(String? textColor) => _$this._textColor = textColor;

  String? _mutedTextColor;
  String? get mutedTextColor => _$this._mutedTextColor;
  set mutedTextColor(String? mutedTextColor) =>
      _$this._mutedTextColor = mutedTextColor;

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

  AppThemeResponseDtoBuilder() {
    AppThemeResponseDto._defaults(this);
  }

  AppThemeResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _mode = $v.mode;
      _backgroundColor = $v.backgroundColor;
      _surfaceColor = $v.surfaceColor;
      _primaryColor = $v.primaryColor;
      _secondaryColor = $v.secondaryColor;
      _accentColor = $v.accentColor;
      _textColor = $v.textColor;
      _mutedTextColor = $v.mutedTextColor;
      _isDefault = $v.isDefault;
      _isActive = $v.isActive;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AppThemeResponseDto other) {
    _$v = other as _$AppThemeResponseDto;
  }

  @override
  void update(void Function(AppThemeResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AppThemeResponseDto build() => _build();

  _$AppThemeResponseDto _build() {
    final _$result = _$v ??
        _$AppThemeResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AppThemeResponseDto', 'id'),
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'AppThemeResponseDto', 'name'),
          mode: BuiltValueNullFieldError.checkNotNull(
              mode, r'AppThemeResponseDto', 'mode'),
          backgroundColor: BuiltValueNullFieldError.checkNotNull(
              backgroundColor, r'AppThemeResponseDto', 'backgroundColor'),
          surfaceColor: BuiltValueNullFieldError.checkNotNull(
              surfaceColor, r'AppThemeResponseDto', 'surfaceColor'),
          primaryColor: BuiltValueNullFieldError.checkNotNull(
              primaryColor, r'AppThemeResponseDto', 'primaryColor'),
          secondaryColor: secondaryColor,
          accentColor: accentColor,
          textColor: BuiltValueNullFieldError.checkNotNull(
              textColor, r'AppThemeResponseDto', 'textColor'),
          mutedTextColor: mutedTextColor,
          isDefault: BuiltValueNullFieldError.checkNotNull(
              isDefault, r'AppThemeResponseDto', 'isDefault'),
          isActive: BuiltValueNullFieldError.checkNotNull(
              isActive, r'AppThemeResponseDto', 'isActive'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AppThemeResponseDto', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'AppThemeResponseDto', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
