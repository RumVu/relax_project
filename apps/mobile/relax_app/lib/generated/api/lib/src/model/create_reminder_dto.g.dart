// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_reminder_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateReminderDto extends CreateReminderDto {
  @override
  final String title;
  @override
  final String? message;
  @override
  final JsonObject? type;
  @override
  final DateTime scheduledAt;
  @override
  final String? repeatRule;
  @override
  final bool? isActive;

  factory _$CreateReminderDto(
          [void Function(CreateReminderDtoBuilder)? updates]) =>
      (CreateReminderDtoBuilder()..update(updates))._build();

  _$CreateReminderDto._(
      {required this.title,
      this.message,
      this.type,
      required this.scheduledAt,
      this.repeatRule,
      this.isActive})
      : super._();
  @override
  CreateReminderDto rebuild(void Function(CreateReminderDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateReminderDtoBuilder toBuilder() =>
      CreateReminderDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateReminderDto &&
        title == other.title &&
        message == other.message &&
        type == other.type &&
        scheduledAt == other.scheduledAt &&
        repeatRule == other.repeatRule &&
        isActive == other.isActive;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, scheduledAt.hashCode);
    _$hash = $jc(_$hash, repeatRule.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateReminderDto')
          ..add('title', title)
          ..add('message', message)
          ..add('type', type)
          ..add('scheduledAt', scheduledAt)
          ..add('repeatRule', repeatRule)
          ..add('isActive', isActive))
        .toString();
  }
}

class CreateReminderDtoBuilder
    implements Builder<CreateReminderDto, CreateReminderDtoBuilder> {
  _$CreateReminderDto? _$v;

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

  CreateReminderDtoBuilder() {
    CreateReminderDto._defaults(this);
  }

  CreateReminderDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _message = $v.message;
      _type = $v.type;
      _scheduledAt = $v.scheduledAt;
      _repeatRule = $v.repeatRule;
      _isActive = $v.isActive;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateReminderDto other) {
    _$v = other as _$CreateReminderDto;
  }

  @override
  void update(void Function(CreateReminderDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateReminderDto build() => _build();

  _$CreateReminderDto _build() {
    final _$result = _$v ??
        _$CreateReminderDto._(
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'CreateReminderDto', 'title'),
          message: message,
          type: type,
          scheduledAt: BuiltValueNullFieldError.checkNotNull(
              scheduledAt, r'CreateReminderDto', 'scheduledAt'),
          repeatRule: repeatRule,
          isActive: isActive,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
