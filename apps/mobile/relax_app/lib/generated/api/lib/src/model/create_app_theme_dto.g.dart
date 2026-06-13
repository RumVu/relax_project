// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_app_theme_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateAppThemeDto extends CreateAppThemeDto {
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
  final bool? isDefault;
  @override
  final bool? isActive;

  factory _$CreateAppThemeDto(
          [void Function(CreateAppThemeDtoBuilder)? updates]) =>
      (CreateAppThemeDtoBuilder()..update(updates))._build();

  _$CreateAppThemeDto._(
      {required this.name,
      required this.mode,
      required this.backgroundColor,
      required this.surfaceColor,
      required this.primaryColor,
      this.secondaryColor,
      this.accentColor,
      required this.textColor,
      this.mutedTextColor,
      this.isDefault,
      this.isActive})
      : super._();
  @override
  CreateAppThemeDto rebuild(void Function(CreateAppThemeDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateAppThemeDtoBuilder toBuilder() =>
      CreateAppThemeDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateAppThemeDto &&
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
        isActive == other.isActive;
  }

  @override
  int get hashCode {
    var _$hash = 0;
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
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateAppThemeDto')
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
          ..add('isActive', isActive))
        .toString();
  }
}

class CreateAppThemeDtoBuilder
    implements Builder<CreateAppThemeDto, CreateAppThemeDtoBuilder> {
  _$CreateAppThemeDto? _$v;

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

  CreateAppThemeDtoBuilder() {
    CreateAppThemeDto._defaults(this);
  }

  CreateAppThemeDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
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
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateAppThemeDto other) {
    _$v = other as _$CreateAppThemeDto;
  }

  @override
  void update(void Function(CreateAppThemeDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateAppThemeDto build() => _build();

  _$CreateAppThemeDto _build() {
    final _$result = _$v ??
        _$CreateAppThemeDto._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'CreateAppThemeDto', 'name'),
          mode: BuiltValueNullFieldError.checkNotNull(
              mode, r'CreateAppThemeDto', 'mode'),
          backgroundColor: BuiltValueNullFieldError.checkNotNull(
              backgroundColor, r'CreateAppThemeDto', 'backgroundColor'),
          surfaceColor: BuiltValueNullFieldError.checkNotNull(
              surfaceColor, r'CreateAppThemeDto', 'surfaceColor'),
          primaryColor: BuiltValueNullFieldError.checkNotNull(
              primaryColor, r'CreateAppThemeDto', 'primaryColor'),
          secondaryColor: secondaryColor,
          accentColor: accentColor,
          textColor: BuiltValueNullFieldError.checkNotNull(
              textColor, r'CreateAppThemeDto', 'textColor'),
          mutedTextColor: mutedTextColor,
          isDefault: isDefault,
          isActive: isActive,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
