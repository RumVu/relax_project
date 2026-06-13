// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_log_actor_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminLogActorDto extends AdminLogActorDto {
  @override
  final String id;
  @override
  final String email;
  @override
  final String? name;
  @override
  final JsonObject role;

  factory _$AdminLogActorDto(
          [void Function(AdminLogActorDtoBuilder)? updates]) =>
      (AdminLogActorDtoBuilder()..update(updates))._build();

  _$AdminLogActorDto._(
      {required this.id, required this.email, this.name, required this.role})
      : super._();
  @override
  AdminLogActorDto rebuild(void Function(AdminLogActorDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminLogActorDtoBuilder toBuilder() =>
      AdminLogActorDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminLogActorDto &&
        id == other.id &&
        email == other.email &&
        name == other.name &&
        role == other.role;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminLogActorDto')
          ..add('id', id)
          ..add('email', email)
          ..add('name', name)
          ..add('role', role))
        .toString();
  }
}

class AdminLogActorDtoBuilder
    implements Builder<AdminLogActorDto, AdminLogActorDtoBuilder> {
  _$AdminLogActorDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  JsonObject? _role;
  JsonObject? get role => _$this._role;
  set role(JsonObject? role) => _$this._role = role;

  AdminLogActorDtoBuilder() {
    AdminLogActorDto._defaults(this);
  }

  AdminLogActorDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _name = $v.name;
      _role = $v.role;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminLogActorDto other) {
    _$v = other as _$AdminLogActorDto;
  }

  @override
  void update(void Function(AdminLogActorDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminLogActorDto build() => _build();

  _$AdminLogActorDto _build() {
    final _$result = _$v ??
        _$AdminLogActorDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AdminLogActorDto', 'id'),
          email: BuiltValueNullFieldError.checkNotNull(
              email, r'AdminLogActorDto', 'email'),
          name: name,
          role: BuiltValueNullFieldError.checkNotNull(
              role, r'AdminLogActorDto', 'role'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
