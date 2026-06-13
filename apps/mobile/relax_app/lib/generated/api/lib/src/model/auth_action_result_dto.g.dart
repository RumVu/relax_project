// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_action_result_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthActionResultDto extends AuthActionResultDto {
  @override
  final bool? success;
  @override
  final String? mode;
  @override
  final bool? revokedSessions;
  @override
  final bool? anonymized;
  @override
  final String? devToken;
  @override
  final DateTime? expiresAt;
  @override
  final UserResponseDto? user;

  factory _$AuthActionResultDto(
          [void Function(AuthActionResultDtoBuilder)? updates]) =>
      (AuthActionResultDtoBuilder()..update(updates))._build();

  _$AuthActionResultDto._(
      {this.success,
      this.mode,
      this.revokedSessions,
      this.anonymized,
      this.devToken,
      this.expiresAt,
      this.user})
      : super._();
  @override
  AuthActionResultDto rebuild(
          void Function(AuthActionResultDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthActionResultDtoBuilder toBuilder() =>
      AuthActionResultDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthActionResultDto &&
        success == other.success &&
        mode == other.mode &&
        revokedSessions == other.revokedSessions &&
        anonymized == other.anonymized &&
        devToken == other.devToken &&
        expiresAt == other.expiresAt &&
        user == other.user;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, success.hashCode);
    _$hash = $jc(_$hash, mode.hashCode);
    _$hash = $jc(_$hash, revokedSessions.hashCode);
    _$hash = $jc(_$hash, anonymized.hashCode);
    _$hash = $jc(_$hash, devToken.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthActionResultDto')
          ..add('success', success)
          ..add('mode', mode)
          ..add('revokedSessions', revokedSessions)
          ..add('anonymized', anonymized)
          ..add('devToken', devToken)
          ..add('expiresAt', expiresAt)
          ..add('user', user))
        .toString();
  }
}

class AuthActionResultDtoBuilder
    implements Builder<AuthActionResultDto, AuthActionResultDtoBuilder> {
  _$AuthActionResultDto? _$v;

  bool? _success;
  bool? get success => _$this._success;
  set success(bool? success) => _$this._success = success;

  String? _mode;
  String? get mode => _$this._mode;
  set mode(String? mode) => _$this._mode = mode;

  bool? _revokedSessions;
  bool? get revokedSessions => _$this._revokedSessions;
  set revokedSessions(bool? revokedSessions) =>
      _$this._revokedSessions = revokedSessions;

  bool? _anonymized;
  bool? get anonymized => _$this._anonymized;
  set anonymized(bool? anonymized) => _$this._anonymized = anonymized;

  String? _devToken;
  String? get devToken => _$this._devToken;
  set devToken(String? devToken) => _$this._devToken = devToken;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  UserResponseDtoBuilder? _user;
  UserResponseDtoBuilder get user => _$this._user ??= UserResponseDtoBuilder();
  set user(UserResponseDtoBuilder? user) => _$this._user = user;

  AuthActionResultDtoBuilder() {
    AuthActionResultDto._defaults(this);
  }

  AuthActionResultDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _success = $v.success;
      _mode = $v.mode;
      _revokedSessions = $v.revokedSessions;
      _anonymized = $v.anonymized;
      _devToken = $v.devToken;
      _expiresAt = $v.expiresAt;
      _user = $v.user?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthActionResultDto other) {
    _$v = other as _$AuthActionResultDto;
  }

  @override
  void update(void Function(AuthActionResultDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthActionResultDto build() => _build();

  _$AuthActionResultDto _build() {
    _$AuthActionResultDto _$result;
    try {
      _$result = _$v ??
          _$AuthActionResultDto._(
            success: success,
            mode: mode,
            revokedSessions: revokedSessions,
            anonymized: anonymized,
            devToken: devToken,
            expiresAt: expiresAt,
            user: _user?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'user';
        _user?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AuthActionResultDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
