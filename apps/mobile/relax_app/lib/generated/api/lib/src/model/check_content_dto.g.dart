// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_content_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CheckContentDto extends CheckContentDto {
  @override
  final String text;

  factory _$CheckContentDto([void Function(CheckContentDtoBuilder)? updates]) =>
      (CheckContentDtoBuilder()..update(updates))._build();

  _$CheckContentDto._({required this.text}) : super._();
  @override
  CheckContentDto rebuild(void Function(CheckContentDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CheckContentDtoBuilder toBuilder() => CheckContentDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CheckContentDto && text == other.text;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, text.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CheckContentDto')..add('text', text))
        .toString();
  }
}

class CheckContentDtoBuilder
    implements Builder<CheckContentDto, CheckContentDtoBuilder> {
  _$CheckContentDto? _$v;

  String? _text;
  String? get text => _$this._text;
  set text(String? text) => _$this._text = text;

  CheckContentDtoBuilder() {
    CheckContentDto._defaults(this);
  }

  CheckContentDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _text = $v.text;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CheckContentDto other) {
    _$v = other as _$CheckContentDto;
  }

  @override
  void update(void Function(CheckContentDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CheckContentDto build() => _build();

  _$CheckContentDto _build() {
    final _$result = _$v ??
        _$CheckContentDto._(
          text: BuiltValueNullFieldError.checkNotNull(
              text, r'CheckContentDto', 'text'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
