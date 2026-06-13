// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_email_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VerifyEmailDto extends VerifyEmailDto {
  @override
  final String token;

  factory _$VerifyEmailDto([void Function(VerifyEmailDtoBuilder)? updates]) =>
      (VerifyEmailDtoBuilder()..update(updates))._build();

  _$VerifyEmailDto._({required this.token}) : super._();
  @override
  VerifyEmailDto rebuild(void Function(VerifyEmailDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VerifyEmailDtoBuilder toBuilder() => VerifyEmailDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VerifyEmailDto && token == other.token;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, token.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VerifyEmailDto')..add('token', token))
        .toString();
  }
}

class VerifyEmailDtoBuilder
    implements Builder<VerifyEmailDto, VerifyEmailDtoBuilder> {
  _$VerifyEmailDto? _$v;

  String? _token;
  String? get token => _$this._token;
  set token(String? token) => _$this._token = token;

  VerifyEmailDtoBuilder() {
    VerifyEmailDto._defaults(this);
  }

  VerifyEmailDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _token = $v.token;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VerifyEmailDto other) {
    _$v = other as _$VerifyEmailDto;
  }

  @override
  void update(void Function(VerifyEmailDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VerifyEmailDto build() => _build();

  _$VerifyEmailDto _build() {
    final _$result = _$v ??
        _$VerifyEmailDto._(
          token: BuiltValueNullFieldError.checkNotNull(
              token, r'VerifyEmailDto', 'token'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
