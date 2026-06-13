// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'refresh_token_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RefreshTokenDto extends RefreshTokenDto {
  @override
  final String? refreshToken;

  factory _$RefreshTokenDto([void Function(RefreshTokenDtoBuilder)? updates]) =>
      (RefreshTokenDtoBuilder()..update(updates))._build();

  _$RefreshTokenDto._({this.refreshToken}) : super._();
  @override
  RefreshTokenDto rebuild(void Function(RefreshTokenDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RefreshTokenDtoBuilder toBuilder() => RefreshTokenDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RefreshTokenDto && refreshToken == other.refreshToken;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, refreshToken.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RefreshTokenDto')
          ..add('refreshToken', refreshToken))
        .toString();
  }
}

class RefreshTokenDtoBuilder
    implements Builder<RefreshTokenDto, RefreshTokenDtoBuilder> {
  _$RefreshTokenDto? _$v;

  String? _refreshToken;
  String? get refreshToken => _$this._refreshToken;
  set refreshToken(String? refreshToken) => _$this._refreshToken = refreshToken;

  RefreshTokenDtoBuilder() {
    RefreshTokenDto._defaults(this);
  }

  RefreshTokenDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _refreshToken = $v.refreshToken;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RefreshTokenDto other) {
    _$v = other as _$RefreshTokenDto;
  }

  @override
  void update(void Function(RefreshTokenDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RefreshTokenDto build() => _build();

  _$RefreshTokenDto _build() {
    final _$result = _$v ??
        _$RefreshTokenDto._(
          refreshToken: refreshToken,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
