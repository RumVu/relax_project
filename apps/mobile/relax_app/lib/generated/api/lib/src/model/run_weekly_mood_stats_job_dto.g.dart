// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'run_weekly_mood_stats_job_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RunWeeklyMoodStatsJobDto extends RunWeeklyMoodStatsJobDto {
  @override
  final String? userId;
  @override
  final DateTime? from;
  @override
  final DateTime? to;
  @override
  final String? timezone;
  @override
  final num? limit;

  factory _$RunWeeklyMoodStatsJobDto(
          [void Function(RunWeeklyMoodStatsJobDtoBuilder)? updates]) =>
      (RunWeeklyMoodStatsJobDtoBuilder()..update(updates))._build();

  _$RunWeeklyMoodStatsJobDto._(
      {this.userId, this.from, this.to, this.timezone, this.limit})
      : super._();
  @override
  RunWeeklyMoodStatsJobDto rebuild(
          void Function(RunWeeklyMoodStatsJobDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RunWeeklyMoodStatsJobDtoBuilder toBuilder() =>
      RunWeeklyMoodStatsJobDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RunWeeklyMoodStatsJobDto &&
        userId == other.userId &&
        from == other.from &&
        to == other.to &&
        timezone == other.timezone &&
        limit == other.limit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, from.hashCode);
    _$hash = $jc(_$hash, to.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RunWeeklyMoodStatsJobDto')
          ..add('userId', userId)
          ..add('from', from)
          ..add('to', to)
          ..add('timezone', timezone)
          ..add('limit', limit))
        .toString();
  }
}

class RunWeeklyMoodStatsJobDtoBuilder
    implements
        Builder<RunWeeklyMoodStatsJobDto, RunWeeklyMoodStatsJobDtoBuilder> {
  _$RunWeeklyMoodStatsJobDto? _$v;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  DateTime? _from;
  DateTime? get from => _$this._from;
  set from(DateTime? from) => _$this._from = from;

  DateTime? _to;
  DateTime? get to => _$this._to;
  set to(DateTime? to) => _$this._to = to;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  num? _limit;
  num? get limit => _$this._limit;
  set limit(num? limit) => _$this._limit = limit;

  RunWeeklyMoodStatsJobDtoBuilder() {
    RunWeeklyMoodStatsJobDto._defaults(this);
  }

  RunWeeklyMoodStatsJobDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _userId = $v.userId;
      _from = $v.from;
      _to = $v.to;
      _timezone = $v.timezone;
      _limit = $v.limit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RunWeeklyMoodStatsJobDto other) {
    _$v = other as _$RunWeeklyMoodStatsJobDto;
  }

  @override
  void update(void Function(RunWeeklyMoodStatsJobDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RunWeeklyMoodStatsJobDto build() => _build();

  _$RunWeeklyMoodStatsJobDto _build() {
    final _$result = _$v ??
        _$RunWeeklyMoodStatsJobDto._(
          userId: userId,
          from: from,
          to: to,
          timezone: timezone,
          limit: limit,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
