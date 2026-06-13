// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'finish_relax_session_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FinishRelaxSessionDto extends FinishRelaxSessionDto {
  @override
  final JsonObject? moodAfter;
  @override
  final num? reliefLevel;
  @override
  final String? note;
  @override
  final String? nextActionAccepted;

  factory _$FinishRelaxSessionDto(
          [void Function(FinishRelaxSessionDtoBuilder)? updates]) =>
      (FinishRelaxSessionDtoBuilder()..update(updates))._build();

  _$FinishRelaxSessionDto._(
      {this.moodAfter, this.reliefLevel, this.note, this.nextActionAccepted})
      : super._();
  @override
  FinishRelaxSessionDto rebuild(
          void Function(FinishRelaxSessionDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FinishRelaxSessionDtoBuilder toBuilder() =>
      FinishRelaxSessionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FinishRelaxSessionDto &&
        moodAfter == other.moodAfter &&
        reliefLevel == other.reliefLevel &&
        note == other.note &&
        nextActionAccepted == other.nextActionAccepted;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, moodAfter.hashCode);
    _$hash = $jc(_$hash, reliefLevel.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, nextActionAccepted.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FinishRelaxSessionDto')
          ..add('moodAfter', moodAfter)
          ..add('reliefLevel', reliefLevel)
          ..add('note', note)
          ..add('nextActionAccepted', nextActionAccepted))
        .toString();
  }
}

class FinishRelaxSessionDtoBuilder
    implements Builder<FinishRelaxSessionDto, FinishRelaxSessionDtoBuilder> {
  _$FinishRelaxSessionDto? _$v;

  JsonObject? _moodAfter;
  JsonObject? get moodAfter => _$this._moodAfter;
  set moodAfter(JsonObject? moodAfter) => _$this._moodAfter = moodAfter;

  num? _reliefLevel;
  num? get reliefLevel => _$this._reliefLevel;
  set reliefLevel(num? reliefLevel) => _$this._reliefLevel = reliefLevel;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  String? _nextActionAccepted;
  String? get nextActionAccepted => _$this._nextActionAccepted;
  set nextActionAccepted(String? nextActionAccepted) =>
      _$this._nextActionAccepted = nextActionAccepted;

  FinishRelaxSessionDtoBuilder() {
    FinishRelaxSessionDto._defaults(this);
  }

  FinishRelaxSessionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _moodAfter = $v.moodAfter;
      _reliefLevel = $v.reliefLevel;
      _note = $v.note;
      _nextActionAccepted = $v.nextActionAccepted;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FinishRelaxSessionDto other) {
    _$v = other as _$FinishRelaxSessionDto;
  }

  @override
  void update(void Function(FinishRelaxSessionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FinishRelaxSessionDto build() => _build();

  _$FinishRelaxSessionDto _build() {
    final _$result = _$v ??
        _$FinishRelaxSessionDto._(
          moodAfter: moodAfter,
          reliefLevel: reliefLevel,
          note: note,
          nextActionAccepted: nextActionAccepted,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
