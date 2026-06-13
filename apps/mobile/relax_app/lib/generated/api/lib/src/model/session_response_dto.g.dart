// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'session_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SessionResponseDto extends SessionResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final String? userAgent;
  @override
  final String? ipAddress;
  @override
  final DateTime expiresAt;
  @override
  final DateTime createdAt;

  factory _$SessionResponseDto(
          [void Function(SessionResponseDtoBuilder)? updates]) =>
      (SessionResponseDtoBuilder()..update(updates))._build();

  _$SessionResponseDto._(
      {required this.id,
      required this.userId,
      this.userAgent,
      this.ipAddress,
      required this.expiresAt,
      required this.createdAt})
      : super._();
  @override
  SessionResponseDto rebuild(
          void Function(SessionResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SessionResponseDtoBuilder toBuilder() =>
      SessionResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SessionResponseDto &&
        id == other.id &&
        userId == other.userId &&
        userAgent == other.userAgent &&
        ipAddress == other.ipAddress &&
        expiresAt == other.expiresAt &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, userAgent.hashCode);
    _$hash = $jc(_$hash, ipAddress.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SessionResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('userAgent', userAgent)
          ..add('ipAddress', ipAddress)
          ..add('expiresAt', expiresAt)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class SessionResponseDtoBuilder
    implements Builder<SessionResponseDto, SessionResponseDtoBuilder> {
  _$SessionResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _userAgent;
  String? get userAgent => _$this._userAgent;
  set userAgent(String? userAgent) => _$this._userAgent = userAgent;

  String? _ipAddress;
  String? get ipAddress => _$this._ipAddress;
  set ipAddress(String? ipAddress) => _$this._ipAddress = ipAddress;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  SessionResponseDtoBuilder() {
    SessionResponseDto._defaults(this);
  }

  SessionResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _userAgent = $v.userAgent;
      _ipAddress = $v.ipAddress;
      _expiresAt = $v.expiresAt;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SessionResponseDto other) {
    _$v = other as _$SessionResponseDto;
  }

  @override
  void update(void Function(SessionResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SessionResponseDto build() => _build();

  _$SessionResponseDto _build() {
    final _$result = _$v ??
        _$SessionResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'SessionResponseDto', 'id'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'SessionResponseDto', 'userId'),
          userAgent: userAgent,
          ipAddress: ipAddress,
          expiresAt: BuiltValueNullFieldError.checkNotNull(
              expiresAt, r'SessionResponseDto', 'expiresAt'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'SessionResponseDto', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
