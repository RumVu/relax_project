// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companion_chat_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CompanionChatDto extends CompanionChatDto {
  @override
  final String message;

  factory _$CompanionChatDto(
          [void Function(CompanionChatDtoBuilder)? updates]) =>
      (CompanionChatDtoBuilder()..update(updates))._build();

  _$CompanionChatDto._({required this.message}) : super._();
  @override
  CompanionChatDto rebuild(void Function(CompanionChatDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CompanionChatDtoBuilder toBuilder() =>
      CompanionChatDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompanionChatDto && message == other.message;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, message.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CompanionChatDto')
          ..add('message', message))
        .toString();
  }
}

class CompanionChatDtoBuilder
    implements Builder<CompanionChatDto, CompanionChatDtoBuilder> {
  _$CompanionChatDto? _$v;

  String? _message;
  String? get message => _$this._message;
  set message(String? message) => _$this._message = message;

  CompanionChatDtoBuilder() {
    CompanionChatDto._defaults(this);
  }

  CompanionChatDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _message = $v.message;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CompanionChatDto other) {
    _$v = other as _$CompanionChatDto;
  }

  @override
  void update(void Function(CompanionChatDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CompanionChatDto build() => _build();

  _$CompanionChatDto _build() {
    final _$result = _$v ??
        _$CompanionChatDto._(
          message: BuiltValueNullFieldError.checkNotNull(
              message, r'CompanionChatDto', 'message'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
