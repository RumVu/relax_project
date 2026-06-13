// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_user_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateUserDto extends CreateUserDto {
  @override
  final String email;
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

  factory _$CreateUserDto([void Function(CreateUserDtoBuilder)? updates]) =>
      (CreateUserDtoBuilder()..update(updates))._build();

  _$CreateUserDto._(
      {required this.email,
      this.name,
      this.avatar,
      this.password,
      this.role,
      this.authProvider,
      this.emailVerified,
      this.isActive})
      : super._();
  @override
  CreateUserDto rebuild(void Function(CreateUserDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateUserDtoBuilder toBuilder() => CreateUserDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateUserDto &&
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
    return (newBuiltValueToStringHelper(r'CreateUserDto')
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

class CreateUserDtoBuilder
    implements Builder<CreateUserDto, CreateUserDtoBuilder> {
  _$CreateUserDto? _$v;

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

  CreateUserDtoBuilder() {
    CreateUserDto._defaults(this);
  }

  CreateUserDtoBuilder get _$this {
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
  void replace(CreateUserDto other) {
    _$v = other as _$CreateUserDto;
  }

  @override
  void update(void Function(CreateUserDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateUserDto build() => _build();

  _$CreateUserDto _build() {
    final _$result = _$v ??
        _$CreateUserDto._(
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'CreateUserDto', 'email'),
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
