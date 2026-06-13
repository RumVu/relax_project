// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_log_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminLogResponseDto extends AdminLogResponseDto {
  @override
  final String id;
  @override
  final String adminId;
  @override
  final String action;
  @override
  final String? targetId;
  @override
  final String? targetType;
  @override
  final String details;
  @override
  final DateTime createdAt;
  @override
  final AdminLogActorDto? admin;

  factory _$AdminLogResponseDto(
          [void Function(AdminLogResponseDtoBuilder)? updates]) =>
      (AdminLogResponseDtoBuilder()..update(updates))._build();

  _$AdminLogResponseDto._(
      {required this.id,
      required this.adminId,
      required this.action,
      this.targetId,
      this.targetType,
      required this.details,
      required this.createdAt,
      this.admin})
      : super._();
  @override
  AdminLogResponseDto rebuild(
          void Function(AdminLogResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminLogResponseDtoBuilder toBuilder() =>
      AdminLogResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminLogResponseDto &&
        id == other.id &&
        adminId == other.adminId &&
        action == other.action &&
        targetId == other.targetId &&
        targetType == other.targetType &&
        details == other.details &&
        createdAt == other.createdAt &&
        admin == other.admin;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, adminId.hashCode);
    _$hash = $jc(_$hash, action.hashCode);
    _$hash = $jc(_$hash, targetId.hashCode);
    _$hash = $jc(_$hash, targetType.hashCode);
    _$hash = $jc(_$hash, details.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, admin.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AdminLogResponseDto')
          ..add('id', id)
          ..add('adminId', adminId)
          ..add('action', action)
          ..add('targetId', targetId)
          ..add('targetType', targetType)
          ..add('details', details)
          ..add('createdAt', createdAt)
          ..add('admin', admin))
        .toString();
  }
}

class AdminLogResponseDtoBuilder
    implements Builder<AdminLogResponseDto, AdminLogResponseDtoBuilder> {
  _$AdminLogResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _adminId;
  String? get adminId => _$this._adminId;
  set adminId(String? adminId) => _$this._adminId = adminId;

  String? _action;
  String? get action => _$this._action;
  set action(String? action) => _$this._action = action;

  String? _targetId;
  String? get targetId => _$this._targetId;
  set targetId(String? targetId) => _$this._targetId = targetId;

  String? _targetType;
  String? get targetType => _$this._targetType;
  set targetType(String? targetType) => _$this._targetType = targetType;

  String? _details;
  String? get details => _$this._details;
  set details(String? details) => _$this._details = details;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  AdminLogActorDtoBuilder? _admin;
  AdminLogActorDtoBuilder get admin =>
      _$this._admin ??= AdminLogActorDtoBuilder();
  set admin(AdminLogActorDtoBuilder? admin) => _$this._admin = admin;

  AdminLogResponseDtoBuilder() {
    AdminLogResponseDto._defaults(this);
  }

  AdminLogResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _adminId = $v.adminId;
      _action = $v.action;
      _targetId = $v.targetId;
      _targetType = $v.targetType;
      _details = $v.details;
      _createdAt = $v.createdAt;
      _admin = $v.admin?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AdminLogResponseDto other) {
    _$v = other as _$AdminLogResponseDto;
  }

  @override
  void update(void Function(AdminLogResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminLogResponseDto build() => _build();

  _$AdminLogResponseDto _build() {
    _$AdminLogResponseDto _$result;
    try {
      _$result = _$v ??
          _$AdminLogResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'AdminLogResponseDto', 'id'),
            adminId: BuiltValueNullFieldError.checkNotNull(
                adminId, r'AdminLogResponseDto', 'adminId'),
            action: BuiltValueNullFieldError.checkNotNull(
                action, r'AdminLogResponseDto', 'action'),
            targetId: targetId,
            targetType: targetType,
            details: BuiltValueNullFieldError.checkNotNull(
                details, r'AdminLogResponseDto', 'details'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'AdminLogResponseDto', 'createdAt'),
            admin: _admin?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'admin';
        _admin?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdminLogResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
