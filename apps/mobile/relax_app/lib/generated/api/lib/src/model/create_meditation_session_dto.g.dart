// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_meditation_session_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateMeditationSessionDto extends CreateMeditationSessionDto {
  @override
  final String? guideId;
  @override
  final num duration;
  @override
  final String startedAt;
  @override
  final String? endedAt;
  @override
  final String? focusArea;
  @override
  final JsonObject? mood;
  @override
  final num? quality;
  @override
  final String? notes;

  factory _$CreateMeditationSessionDto(
          [void Function(CreateMeditationSessionDtoBuilder)? updates]) =>
      (CreateMeditationSessionDtoBuilder()..update(updates))._build();

  _$CreateMeditationSessionDto._(
      {this.guideId,
      required this.duration,
      required this.startedAt,
      this.endedAt,
      this.focusArea,
      this.mood,
      this.quality,
      this.notes})
      : super._();
  @override
  CreateMeditationSessionDto rebuild(
          void Function(CreateMeditationSessionDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateMeditationSessionDtoBuilder toBuilder() =>
      CreateMeditationSessionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateMeditationSessionDto &&
        guideId == other.guideId &&
        duration == other.duration &&
        startedAt == other.startedAt &&
        endedAt == other.endedAt &&
        focusArea == other.focusArea &&
        mood == other.mood &&
        quality == other.quality &&
        notes == other.notes;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, guideId.hashCode);
    _$hash = $jc(_$hash, duration.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jc(_$hash, focusArea.hashCode);
    _$hash = $jc(_$hash, mood.hashCode);
    _$hash = $jc(_$hash, quality.hashCode);
    _$hash = $jc(_$hash, notes.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateMeditationSessionDto')
          ..add('guideId', guideId)
          ..add('duration', duration)
          ..add('startedAt', startedAt)
          ..add('endedAt', endedAt)
          ..add('focusArea', focusArea)
          ..add('mood', mood)
          ..add('quality', quality)
          ..add('notes', notes))
        .toString();
  }
}

class CreateMeditationSessionDtoBuilder
    implements
        Builder<CreateMeditationSessionDto, CreateMeditationSessionDtoBuilder> {
  _$CreateMeditationSessionDto? _$v;

  String? _guideId;
  String? get guideId => _$this._guideId;
  set guideId(String? guideId) => _$this._guideId = guideId;

  num? _duration;
  num? get duration => _$this._duration;
  set duration(num? duration) => _$this._duration = duration;

  String? _startedAt;
  String? get startedAt => _$this._startedAt;
  set startedAt(String? startedAt) => _$this._startedAt = startedAt;

  String? _endedAt;
  String? get endedAt => _$this._endedAt;
  set endedAt(String? endedAt) => _$this._endedAt = endedAt;

  String? _focusArea;
  String? get focusArea => _$this._focusArea;
  set focusArea(String? focusArea) => _$this._focusArea = focusArea;

  JsonObject? _mood;
  JsonObject? get mood => _$this._mood;
  set mood(JsonObject? mood) => _$this._mood = mood;

  num? _quality;
  num? get quality => _$this._quality;
  set quality(num? quality) => _$this._quality = quality;

  String? _notes;
  String? get notes => _$this._notes;
  set notes(String? notes) => _$this._notes = notes;

  CreateMeditationSessionDtoBuilder() {
    CreateMeditationSessionDto._defaults(this);
  }

  CreateMeditationSessionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _guideId = $v.guideId;
      _duration = $v.duration;
      _startedAt = $v.startedAt;
      _endedAt = $v.endedAt;
      _focusArea = $v.focusArea;
      _mood = $v.mood;
      _quality = $v.quality;
      _notes = $v.notes;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateMeditationSessionDto other) {
    _$v = other as _$CreateMeditationSessionDto;
  }

  @override
  void update(void Function(CreateMeditationSessionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateMeditationSessionDto build() => _build();

  _$CreateMeditationSessionDto _build() {
    final _$result = _$v ??
        _$CreateMeditationSessionDto._(
          guideId: guideId,
          duration: BuiltValueNullFieldError.checkNotNull(
              duration, r'CreateMeditationSessionDto', 'duration'),
          startedAt: BuiltValueNullFieldError.checkNotNull(
              startedAt, r'CreateMeditationSessionDto', 'startedAt'),
          endedAt: endedAt,
          focusArea: focusArea,
          mood: mood,
          quality: quality,
          notes: notes,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
