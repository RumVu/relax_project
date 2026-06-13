// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReminderResponseDto extends ReminderResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final String title;
  @override
  final String? message;
  @override
  final JsonObject type;
  @override
  final DateTime scheduledAt;
  @override
  final String? repeatRule;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$ReminderResponseDto(
          [void Function(ReminderResponseDtoBuilder)? updates]) =>
      (ReminderResponseDtoBuilder()..update(updates))._build();

  _$ReminderResponseDto._(
      {required this.id,
      required this.userId,
      required this.title,
      this.message,
      required this.type,
      required this.scheduledAt,
      this.repeatRule,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  ReminderResponseDto rebuild(
          void Function(ReminderResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReminderResponseDtoBuilder toBuilder() =>
      ReminderResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReminderResponseDto &&
        id == other.id &&
        userId == other.userId &&
        title == other.title &&
        message == other.message &&
        type == other.type &&
        scheduledAt == other.scheduledAt &&
        repeatRule == other.repeatRule &&
        isActive == other.isActive &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, scheduledAt.hashCode);
    _$hash = $jc(_$hash, repeatRule.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ReminderResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('title', title)
          ..add('message', message)
          ..add('type', type)
          ..add('scheduledAt', scheduledAt)
          ..add('repeatRule', repeatRule)
          ..add('isActive', isActive)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class ReminderResponseDtoBuilder
    implements Builder<ReminderResponseDto, ReminderResponseDtoBuilder> {
  _$ReminderResponseDto? _$v;

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

  DateTime? _scheduledAt;
  DateTime? get scheduledAt => _$this._scheduledAt;
  set scheduledAt(DateTime? scheduledAt) => _$this._scheduledAt = scheduledAt;

  String? _repeatRule;
  String? get repeatRule => _$this._repeatRule;
  set repeatRule(String? repeatRule) => _$this._repeatRule = repeatRule;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  ReminderResponseDtoBuilder() {
    ReminderResponseDto._defaults(this);
  }

  ReminderResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _title = $v.title;
      _message = $v.message;
      _type = $v.type;
      _scheduledAt = $v.scheduledAt;
      _repeatRule = $v.repeatRule;
      _isActive = $v.isActive;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ReminderResponseDto other) {
    _$v = other as _$ReminderResponseDto;
  }

  @override
  void update(void Function(ReminderResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReminderResponseDto build() => _build();

  _$ReminderResponseDto _build() {
    final _$result = _$v ??
        _$ReminderResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'ReminderResponseDto', 'id'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'ReminderResponseDto', 'userId'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'ReminderResponseDto', 'title'),
          message: message,
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'ReminderResponseDto', 'type'),
          scheduledAt: BuiltValueNullFieldError.checkNotNull(
              scheduledAt, r'ReminderResponseDto', 'scheduledAt'),
          repeatRule: repeatRule,
          isActive: BuiltValueNullFieldError.checkNotNull(
              isActive, r'ReminderResponseDto', 'isActive'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'ReminderResponseDto', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'ReminderResponseDto', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
