// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_checkin_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MoodCheckinResponseDto extends MoodCheckinResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final JsonObject mood;
  @override
  final num? intensity;
  @override
  final num? rawScore;
  @override
  final num? finalScore;
  @override
  final DateTime? scoredAt;
  @override
  final String? note;
  @override
  final BuiltList<String> tags;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$MoodCheckinResponseDto(
          [void Function(MoodCheckinResponseDtoBuilder)? updates]) =>
      (MoodCheckinResponseDtoBuilder()..update(updates))._build();

  _$MoodCheckinResponseDto._(
      {required this.id,
      required this.userId,
      required this.mood,
      this.intensity,
      this.rawScore,
      this.finalScore,
      this.scoredAt,
      this.note,
      required this.tags,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  MoodCheckinResponseDto rebuild(
          void Function(MoodCheckinResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MoodCheckinResponseDtoBuilder toBuilder() =>
      MoodCheckinResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MoodCheckinResponseDto &&
        id == other.id &&
        userId == other.userId &&
        mood == other.mood &&
        intensity == other.intensity &&
        rawScore == other.rawScore &&
        finalScore == other.finalScore &&
        scoredAt == other.scoredAt &&
        note == other.note &&
        tags == other.tags &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, mood.hashCode);
    _$hash = $jc(_$hash, intensity.hashCode);
    _$hash = $jc(_$hash, rawScore.hashCode);
    _$hash = $jc(_$hash, finalScore.hashCode);
    _$hash = $jc(_$hash, scoredAt.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, tags.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'MoodCheckinResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('mood', mood)
          ..add('intensity', intensity)
          ..add('rawScore', rawScore)
          ..add('finalScore', finalScore)
          ..add('scoredAt', scoredAt)
          ..add('note', note)
          ..add('tags', tags)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class MoodCheckinResponseDtoBuilder
    implements Builder<MoodCheckinResponseDto, MoodCheckinResponseDtoBuilder> {
  _$MoodCheckinResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  JsonObject? _mood;
  JsonObject? get mood => _$this._mood;
  set mood(JsonObject? mood) => _$this._mood = mood;

  num? _intensity;
  num? get intensity => _$this._intensity;
  set intensity(num? intensity) => _$this._intensity = intensity;

  num? _rawScore;
  num? get rawScore => _$this._rawScore;
  set rawScore(num? rawScore) => _$this._rawScore = rawScore;

  num? _finalScore;
  num? get finalScore => _$this._finalScore;
  set finalScore(num? finalScore) => _$this._finalScore = finalScore;

  DateTime? _scoredAt;
  DateTime? get scoredAt => _$this._scoredAt;
  set scoredAt(DateTime? scoredAt) => _$this._scoredAt = scoredAt;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  ListBuilder<String>? _tags;
  ListBuilder<String> get tags => _$this._tags ??= ListBuilder<String>();
  set tags(ListBuilder<String>? tags) => _$this._tags = tags;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  MoodCheckinResponseDtoBuilder() {
    MoodCheckinResponseDto._defaults(this);
  }

  MoodCheckinResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _mood = $v.mood;
      _intensity = $v.intensity;
      _rawScore = $v.rawScore;
      _finalScore = $v.finalScore;
      _scoredAt = $v.scoredAt;
      _note = $v.note;
      _tags = $v.tags.toBuilder();
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(MoodCheckinResponseDto other) {
    _$v = other as _$MoodCheckinResponseDto;
  }

  @override
  void update(void Function(MoodCheckinResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MoodCheckinResponseDto build() => _build();

  _$MoodCheckinResponseDto _build() {
    _$MoodCheckinResponseDto _$result;
    try {
      _$result = _$v ??
          _$MoodCheckinResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'MoodCheckinResponseDto', 'id'),
            userId: BuiltValueNullFieldError.checkNotNull(
                userId, r'MoodCheckinResponseDto', 'userId'),
            mood: BuiltValueNullFieldError.checkNotNull(
                mood, r'MoodCheckinResponseDto', 'mood'),
            intensity: intensity,
            rawScore: rawScore,
            finalScore: finalScore,
            scoredAt: scoredAt,
            note: note,
            tags: tags.build(),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'MoodCheckinResponseDto', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'MoodCheckinResponseDto', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tags';
        tags.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MoodCheckinResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
