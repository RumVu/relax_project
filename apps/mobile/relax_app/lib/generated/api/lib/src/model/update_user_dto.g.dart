// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_user_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateUserDto extends UpdateUserDto {
  @override
  final String? email;
  @override
  final String? name;
  @override
  final String? avatar;
  @override
  final String? password;
  @override
  final JsonObject? role;
  @override
  final JsonObject? authProvider;
  @override
  final bool? emailVerified;
  @override
  final bool? isActive;

  factory _$UpdateUserDto([void Function(UpdateUserDtoBuilder)? updates]) =>
      (UpdateUserDtoBuilder()..update(updates))._build();

  _$UpdateUserDto._(
      {this.email,
      this.name,
      this.avatar,
      this.password,
      this.role,
      this.authProvider,
      this.emailVerified,
      this.isActive})
      : super._();
  @override
  UpdateUserDto rebuild(void Function(UpdateUserDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateUserDtoBuilder toBuilder() => UpdateUserDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateUserDto &&
        email == other.email &&
        name == other.name &&
        avatar == other.avatar &&
        password == other.password &&
        role == other.role &&
        authProvider == other.authProvider &&
        emailVerified == other.emailVerified &&
        isActive == other.isActive;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, authProvider.hashCode);
    _$hash = $jc(_$hash, emailVerified.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateUserDto')
          ..add('email', email)
          ..add('name', name)
          ..add('avatar', avatar)
          ..add('password', password)
          ..add('role', role)
          ..add('authProvider', authProvider)
          ..add('emailVerified', emailVerified)
          ..add('isActive', isActive))
        .toString();
  }
}

class UpdateUserDtoBuilder
    implements Builder<UpdateUserDto, UpdateUserDtoBuilder> {
  _$UpdateUserDto? _$v;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _avatar;
  String? get avatar => _$this._avatar;
  set avatar(String? avatar) => _$this._avatar = avatar;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  JsonObject? _role;
  JsonObject? get role => _$this._role;
  set role(JsonObject? role) => _$this._role = role;

  JsonObject? _authProvider;
  JsonObject? get authProvider => _$this._authProvider;
  set authProvider(JsonObject? authProvider) =>
      _$this._authProvider = authProvider;

  bool? _emailVerified;
  bool? get emailVerified => _$this._emailVerified;
  set emailVerified(bool? emailVerified) =>
      _$this._emailVerified = emailVerified;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  UpdateUserDtoBuilder() {
    UpdateUserDto._defaults(this);
  }

  UpdateUserDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _email = $v.email;
      _name = $v.name;
      _avatar = $v.avatar;
      _password = $v.password;
      _role = $v.role;
      _authProvider = $v.authProvider;
      _emailVerified = $v.emailVerified;
      _isActive = $v.isActive;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateUserDto other) {
    _$v = other as _$UpdateUserDto;
  }

  @override
  void update(void Function(UpdateUserDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateUserDto build() => _build();

  _$UpdateUserDto _build() {
    final _$result = _$v ??
        _$UpdateUserDto._(
          email: email,
          name: name,
          avatar: avatar,
          password: password,
          role: role,
          authProvider: authProvider,
          emailVerified: emailVerified,
          isActive: isActive,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
