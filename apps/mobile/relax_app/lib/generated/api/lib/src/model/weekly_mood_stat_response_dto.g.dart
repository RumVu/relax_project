// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weekly_mood_stat_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WeeklyMoodStatResponseDto extends WeeklyMoodStatResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final DateTime weekStart;
  @override
  final num avgScore;
  @override
  final num stressReducePct;
  @override
  final num streakDays;
  @override
  final JsonObject? dominantMood;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$WeeklyMoodStatResponseDto(
          [void Function(WeeklyMoodStatResponseDtoBuilder)? updates]) =>
      (WeeklyMoodStatResponseDtoBuilder()..update(updates))._build();

  _$WeeklyMoodStatResponseDto._(
      {required this.id,
      required this.userId,
      required this.weekStart,
      required this.avgScore,
      required this.stressReducePct,
      required this.streakDays,
      this.dominantMood,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  WeeklyMoodStatResponseDto rebuild(
          void Function(WeeklyMoodStatResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WeeklyMoodStatResponseDtoBuilder toBuilder() =>
      WeeklyMoodStatResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WeeklyMoodStatResponseDto &&
        id == other.id &&
        userId == other.userId &&
        weekStart == other.weekStart &&
        avgScore == other.avgScore &&
        stressReducePct == other.stressReducePct &&
        streakDays == other.streakDays &&
        dominantMood == other.dominantMood &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, weekStart.hashCode);
    _$hash = $jc(_$hash, avgScore.hashCode);
    _$hash = $jc(_$hash, stressReducePct.hashCode);
    _$hash = $jc(_$hash, streakDays.hashCode);
    _$hash = $jc(_$hash, dominantMood.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WeeklyMoodStatResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('weekStart', weekStart)
          ..add('avgScore', avgScore)
          ..add('stressReducePct', stressReducePct)
          ..add('streakDays', streakDays)
          ..add('dominantMood', dominantMood)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class WeeklyMoodStatResponseDtoBuilder
    implements
        Builder<WeeklyMoodStatResponseDto, WeeklyMoodStatResponseDtoBuilder> {
  _$WeeklyMoodStatResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  DateTime? _weekStart;
  DateTime? get weekStart => _$this._weekStart;
  set weekStart(DateTime? weekStart) => _$this._weekStart = weekStart;

  num? _avgScore;
  num? get avgScore => _$this._avgScore;
  set avgScore(num? avgScore) => _$this._avgScore = avgScore;

  num? _stressReducePct;
  num? get stressReducePct => _$this._stressReducePct;
  set stressReducePct(num? stressReducePct) =>
      _$this._stressReducePct = stressReducePct;

  num? _streakDays;
  num? get streakDays => _$this._streakDays;
  set streakDays(num? streakDays) => _$this._streakDays = streakDays;

  JsonObject? _dominantMood;
  JsonObject? get dominantMood => _$this._dominantMood;
  set dominantMood(JsonObject? dominantMood) =>
      _$this._dominantMood = dominantMood;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  WeeklyMoodStatResponseDtoBuilder() {
    WeeklyMoodStatResponseDto._defaults(this);
  }

  WeeklyMoodStatResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _weekStart = $v.weekStart;
      _avgScore = $v.avgScore;
      _stressReducePct = $v.stressReducePct;
      _streakDays = $v.streakDays;
      _dominantMood = $v.dominantMood;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WeeklyMoodStatResponseDto other) {
    _$v = other as _$WeeklyMoodStatResponseDto;
  }

  @override
  void update(void Function(WeeklyMoodStatResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WeeklyMoodStatResponseDto build() => _build();

  _$WeeklyMoodStatResponseDto _build() {
    final _$result = _$v ??
        _$WeeklyMoodStatResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'WeeklyMoodStatResponseDto', 'id'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'WeeklyMoodStatResponseDto', 'userId'),
          weekStart: BuiltValueNullFieldError.checkNotNull(
              weekStart, r'WeeklyMoodStatResponseDto', 'weekStart'),
          avgScore: BuiltValueNullFieldError.checkNotNull(
              avgScore, r'WeeklyMoodStatResponseDto', 'avgScore'),
          stressReducePct: BuiltValueNullFieldError.checkNotNull(
              stressReducePct, r'WeeklyMoodStatResponseDto', 'stressReducePct'),
          streakDays: BuiltValueNullFieldError.checkNotNull(
              streakDays, r'WeeklyMoodStatResponseDto', 'streakDays'),
          dominantMood: dominantMood,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'WeeklyMoodStatResponseDto', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'WeeklyMoodStatResponseDto', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
