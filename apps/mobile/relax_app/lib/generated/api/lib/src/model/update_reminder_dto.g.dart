// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_reminder_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateReminderDto extends UpdateReminderDto {
  @override
  final String? title;
  @override
  final String? message;
  @override
  final JsonObject? type;
  @override
  final DateTime? scheduledAt;
  @override
  final String? repeatRule;
  @override
  final bool? isActive;

  factory _$UpdateReminderDto(
          [void Function(UpdateReminderDtoBuilder)? updates]) =>
      (UpdateReminderDtoBuilder()..update(updates))._build();

  _$UpdateReminderDto._(
      {this.title,
      this.message,
      this.type,
      this.scheduledAt,
      this.repeatRule,
      this.isActive})
      : super._();
  @override
  UpdateReminderDto rebuild(void Function(UpdateReminderDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateReminderDtoBuilder toBuilder() =>
      UpdateReminderDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateReminderDto &&
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
    return (newBuiltValueToStringHelper(r'UpdateReminderDto')
          ..add('title', title)
          ..add('message', message)
          ..add('type', type)
          ..add('scheduledAt', scheduledAt)
          ..add('repeatRule', repeatRule)
          ..add('isActive', isActive))
        .toString();
  }
}

class UpdateReminderDtoBuilder
    implements Builder<UpdateReminderDto, UpdateReminderDtoBuilder> {
  _$UpdateReminderDto? _$v;

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

  UpdateReminderDtoBuilder() {
    UpdateReminderDto._defaults(this);
  }

  UpdateReminderDtoBuilder get _$this {
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
  void replace(UpdateReminderDto other) {
    _$v = other as _$UpdateReminderDto;
  }

  @override
  void update(void Function(UpdateReminderDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateReminderDto build() => _build();

  _$UpdateReminderDto _build() {
    final _$result = _$v ??
        _$UpdateReminderDto._(
          title: title,
          message: message,
          type: type,
          scheduledAt: scheduledAt,
          repeatRule: repeatRule,
          isActive: isActive,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
