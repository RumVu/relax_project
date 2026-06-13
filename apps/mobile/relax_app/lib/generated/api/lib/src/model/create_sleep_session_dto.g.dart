// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_sleep_session_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateSleepSessionDto extends CreateSleepSessionDto {
  @override
  final String startedAt;
  @override
  final String? endedAt;
  @override
  final num? quality;
  @override
  final String? note;

  factory _$CreateSleepSessionDto(
          [void Function(CreateSleepSessionDtoBuilder)? updates]) =>
      (CreateSleepSessionDtoBuilder()..update(updates))._build();

  _$CreateSleepSessionDto._(
      {required this.startedAt, this.endedAt, this.quality, this.note})
      : super._();
  @override
  CreateSleepSessionDto rebuild(
          void Function(CreateSleepSessionDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateSleepSessionDtoBuilder toBuilder() =>
      CreateSleepSessionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateSleepSessionDto &&
        startedAt == other.startedAt &&
        endedAt == other.endedAt &&
        quality == other.quality &&
        note == other.note;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jc(_$hash, quality.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateSleepSessionDto')
          ..add('startedAt', startedAt)
          ..add('endedAt', endedAt)
          ..add('quality', quality)
          ..add('note', note))
        .toString();
  }
}

class CreateSleepSessionDtoBuilder
    implements Builder<CreateSleepSessionDto, CreateSleepSessionDtoBuilder> {
  _$CreateSleepSessionDto? _$v;

  String? _startedAt;
  String? get startedAt => _$this._startedAt;
  set startedAt(String? startedAt) => _$this._startedAt = startedAt;

  String? _endedAt;
  String? get endedAt => _$this._endedAt;
  set endedAt(String? endedAt) => _$this._endedAt = endedAt;

  num? _quality;
  num? get quality => _$this._quality;
  set quality(num? quality) => _$this._quality = quality;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  CreateSleepSessionDtoBuilder() {
    CreateSleepSessionDto._defaults(this);
  }

  CreateSleepSessionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _startedAt = $v.startedAt;
      _endedAt = $v.endedAt;
      _quality = $v.quality;
      _note = $v.note;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateSleepSessionDto other) {
    _$v = other as _$CreateSleepSessionDto;
  }

  @override
  void update(void Function(CreateSleepSessionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateSleepSessionDto build() => _build();

  _$CreateSleepSessionDto _build() {
    final _$result = _$v ??
        _$CreateSleepSessionDto._(
          startedAt: BuiltValueNullFieldError.checkNotNull(
              startedAt, r'CreateSleepSessionDto', 'startedAt'),
          endedAt: endedAt,
          quality: quality,
          note: note,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
