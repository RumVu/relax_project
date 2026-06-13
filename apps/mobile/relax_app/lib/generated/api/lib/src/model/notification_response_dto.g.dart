// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationResponseDto extends NotificationResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final String title;
  @override
  final String message;
  @override
  final JsonObject type;
  @override
  final String? relatedEntity;
  @override
  final String? relatedId;
  @override
  final bool isRead;
  @override
  final DateTime? readAt;
  @override
  final DateTime createdAt;

  factory _$NotificationResponseDto(
          [void Function(NotificationResponseDtoBuilder)? updates]) =>
      (NotificationResponseDtoBuilder()..update(updates))._build();

  _$NotificationResponseDto._(
      {required this.id,
      required this.userId,
      required this.title,
      required this.message,
      required this.type,
      this.relatedEntity,
      this.relatedId,
      required this.isRead,
      this.readAt,
      required this.createdAt})
      : super._();
  @override
  NotificationResponseDto rebuild(
          void Function(NotificationResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationResponseDtoBuilder toBuilder() =>
      NotificationResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationResponseDto &&
        id == other.id &&
        userId == other.userId &&
        title == other.title &&
        message == other.message &&
        type == other.type &&
        relatedEntity == other.relatedEntity &&
        relatedId == other.relatedId &&
        isRead == other.isRead &&
        readAt == other.readAt &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, relatedEntity.hashCode);
    _$hash = $jc(_$hash, relatedId.hashCode);
    _$hash = $jc(_$hash, isRead.hashCode);
    _$hash = $jc(_$hash, readAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'NotificationResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('title', title)
          ..add('message', message)
          ..add('type', type)
          ..add('relatedEntity', relatedEntity)
          ..add('relatedId', relatedId)
          ..add('isRead', isRead)
          ..add('readAt', readAt)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class NotificationResponseDtoBuilder
    implements
        Builder<NotificationResponseDto, NotificationResponseDtoBuilder> {
  _$NotificationResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  JsonObject? _type;
  JsonObject? get type => _$this._type;
  set type(JsonObject? type) => _$this._type = type;

  String? _relatedEntity;
  String? get relatedEntity => _$this._relatedEntity;
  set relatedEntity(String? relatedEntity) =>
      _$this._relatedEntity = relatedEntity;

  String? _relatedId;
  String? get relatedId => _$this._relatedId;
  set relatedId(String? relatedId) => _$this._relatedId = relatedId;

  bool? _isRead;
  bool? get isRead => _$this._isRead;
  set isRead(bool? isRead) => _$this._isRead = isRead;

  DateTime? _readAt;
  DateTime? get readAt => _$this._readAt;
  set readAt(DateTime? readAt) => _$this._readAt = readAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  NotificationResponseDtoBuilder() {
    NotificationResponseDto._defaults(this);
  }

  NotificationResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _title = $v.title;
      _message = $v.message;
      _type = $v.type;
      _relatedEntity = $v.relatedEntity;
      _relatedId = $v.relatedId;
      _isRead = $v.isRead;
      _readAt = $v.readAt;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(NotificationResponseDto other) {
    _$v = other as _$NotificationResponseDto;
  }

  @override
  void update(void Function(NotificationResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationResponseDto build() => _build();

  _$NotificationResponseDto _build() {
    final _$result = _$v ??
        _$NotificationResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'NotificationResponseDto', 'id'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'NotificationResponseDto', 'userId'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'NotificationResponseDto', 'title'),
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'NotificationResponseDto', 'message'),
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'NotificationResponseDto', 'type'),
          relatedEntity: relatedEntity,
          relatedId: relatedId,
          isRead: BuiltValueNullFieldError.checkNotNull(
              isRead, r'NotificationResponseDto', 'isRead'),
          readAt: readAt,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'NotificationResponseDto', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
