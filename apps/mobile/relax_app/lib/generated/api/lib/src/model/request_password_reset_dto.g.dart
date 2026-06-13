// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'request_password_reset_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RequestPasswordResetDto extends RequestPasswordResetDto {
  @override
  final String email;

  factory _$RequestPasswordResetDto(
          [void Function(RequestPasswordResetDtoBuilder)? updates]) =>
      (RequestPasswordResetDtoBuilder()..update(updates))._build();

  _$RequestPasswordResetDto._({required this.email}) : super._();
  @override
  RequestPasswordResetDto rebuild(
          void Function(RequestPasswordResetDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RequestPasswordResetDtoBuilder toBuilder() =>
      RequestPasswordResetDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RequestPasswordResetDto && email == other.email;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RequestPasswordResetDto')
          ..add('email', email))
        .toString();
  }
}

class RequestPasswordResetDtoBuilder
    implements
        Builder<RequestPasswordResetDto, RequestPasswordResetDtoBuilder> {
  _$RequestPasswordResetDto? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  RequestPasswordResetDtoBuilder() {
    RequestPasswordResetDto._defaults(this);
  }

  RequestPasswordResetDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RequestPasswordResetDto other) {
    _$v = other as _$RequestPasswordResetDto;
  }

  @override
  void update(void Function(RequestPasswordResetDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RequestPasswordResetDto build() => _build();

  _$RequestPasswordResetDto _build() {
    final _$result = _$v ??
        _$RequestPasswordResetDto._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'RequestPasswordResetDto', 'email'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
