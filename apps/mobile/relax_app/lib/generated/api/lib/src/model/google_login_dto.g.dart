// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_login_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GoogleLoginDto extends GoogleLoginDto {
  @override
  final String? idToken;
  @override
  final String? accessToken;
  @override
  final String? authorizationCode;
  @override
  final String? redirectUri;

  factory _$GoogleLoginDto([void Function(GoogleLoginDtoBuilder)? updates]) =>
      (GoogleLoginDtoBuilder()..update(updates))._build();

  _$GoogleLoginDto._(
      {this.idToken,
      this.accessToken,
      this.authorizationCode,
      this.redirectUri})
      : super._();
  @override
  GoogleLoginDto rebuild(void Function(GoogleLoginDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GoogleLoginDtoBuilder toBuilder() => GoogleLoginDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GoogleLoginDto &&
        idToken == other.idToken &&
        accessToken == other.accessToken &&
        authorizationCode == other.authorizationCode &&
        redirectUri == other.redirectUri;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, idToken.hashCode);
    _$hash = $jc(_$hash, accessToken.hashCode);
    _$hash = $jc(_$hash, authorizationCode.hashCode);
    _$hash = $jc(_$hash, redirectUri.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'GoogleLoginDto')
          ..add('idToken', idToken)
          ..add('accessToken', accessToken)
          ..add('authorizationCode', authorizationCode)
          ..add('redirectUri', redirectUri))
        .toString();
  }
}

class GoogleLoginDtoBuilder
    implements Builder<GoogleLoginDto, GoogleLoginDtoBuilder> {
  _$GoogleLoginDto? _$v;

  String? _idToken;
  String? get idToken => _$this._idToken;
  set idToken(String? idToken) => _$this._idToken = idToken;

  String? _accessToken;
  String? get accessToken => _$this._accessToken;
  set accessToken(String? accessToken) => _$this._accessToken = accessToken;

  String? _authorizationCode;
  String? get authorizationCode => _$this._authorizationCode;
  set authorizationCode(String? authorizationCode) =>
      _$this._authorizationCode = authorizationCode;

  String? _redirectUri;
  String? get redirectUri => _$this._redirectUri;
  set redirectUri(String? redirectUri) => _$this._redirectUri = redirectUri;

  GoogleLoginDtoBuilder() {
    GoogleLoginDto._defaults(this);
  }

  GoogleLoginDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _idToken = $v.idToken;
      _accessToken = $v.accessToken;
      _authorizationCode = $v.authorizationCode;
      _redirectUri = $v.redirectUri;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GoogleLoginDto other) {
    _$v = other as _$GoogleLoginDto;
  }

  @override
  void update(void Function(GoogleLoginDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GoogleLoginDto build() => _build();

  _$GoogleLoginDto _build() {
    final _$result = _$v ??
        _$GoogleLoginDto._(
          idToken: idToken,
          accessToken: accessToken,
          authorizationCode: authorizationCode,
          redirectUri: redirectUri,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
