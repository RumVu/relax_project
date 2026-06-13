// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_notification_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateNotificationDto extends CreateNotificationDto {
  @override
  final String title;
  @override
  final String message;
  @override
  final JsonObject? type;

  factory _$CreateNotificationDto(
          [void Function(CreateNotificationDtoBuilder)? updates]) =>
      (CreateNotificationDtoBuilder()..update(updates))._build();

  _$CreateNotificationDto._(
      {required this.title, required this.message, this.type})
      : super._();
  @override
  CreateNotificationDto rebuild(
          void Function(CreateNotificationDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateNotificationDtoBuilder toBuilder() =>
      CreateNotificationDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateNotificationDto &&
        title == other.title &&
        message == other.message &&
        type == other.type;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateNotificationDto')
          ..add('title', title)
          ..add('message', message)
          ..add('type', type))
        .toString();
  }
}

class CreateNotificationDtoBuilder
    implements Builder<CreateNotificationDto, CreateNotificationDtoBuilder> {
  _$CreateNotificationDto? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  JsonObject? _type;
  JsonObject? get type => _$this._type;
  set type(JsonObject? type) => _$this._type = type;

  CreateNotificationDtoBuilder() {
    CreateNotificationDto._defaults(this);
  }

  CreateNotificationDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _message = $v.message;
      _type = $v.type;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateNotificationDto other) {
    _$v = other as _$CreateNotificationDto;
  }

  @override
  void update(void Function(CreateNotificationDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateNotificationDto build() => _build();

  _$CreateNotificationDto _build() {
    final _$result = _$v ??
        _$CreateNotificationDto._(
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'CreateNotificationDto', 'title'),
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'CreateNotificationDto', 'message'),
          type: type,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
