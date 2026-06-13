// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tier_name_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$TierNameDto extends TierNameDto {
  @override
  final String name;

  factory _$TierNameDto([void Function(TierNameDtoBuilder)? updates]) =>
      (TierNameDtoBuilder()..update(updates))._build();

  _$TierNameDto._({required this.name}) : super._();
  @override
  TierNameDto rebuild(void Function(TierNameDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  TierNameDtoBuilder toBuilder() => TierNameDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is TierNameDto && name == other.name;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'TierNameDto')..add('name', name))
        .toString();
  }
}

class TierNameDtoBuilder implements Builder<TierNameDto, TierNameDtoBuilder> {
  _$TierNameDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  TierNameDtoBuilder() {
    TierNameDto._defaults(this);
  }

  TierNameDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(TierNameDto other) {
    _$v = other as _$TierNameDto;
  }

  @override
  void update(void Function(TierNameDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  TierNameDto build() => _build();

  _$TierNameDto _build() {
    final _$result = _$v ??
        _$TierNameDto._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'TierNameDto', 'name'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
