// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recalculate_weekly_mood_stats_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RecalculateWeeklyMoodStatsDto extends RecalculateWeeklyMoodStatsDto {
  @override
  final DateTime? from;
  @override
  final DateTime? to;
  @override
  final String? timezone;

  factory _$RecalculateWeeklyMoodStatsDto(
          [void Function(RecalculateWeeklyMoodStatsDtoBuilder)? updates]) =>
      (RecalculateWeeklyMoodStatsDtoBuilder()..update(updates))._build();

  _$RecalculateWeeklyMoodStatsDto._({this.from, this.to, this.timezone})
      : super._();
  @override
  RecalculateWeeklyMoodStatsDto rebuild(
          void Function(RecalculateWeeklyMoodStatsDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RecalculateWeeklyMoodStatsDtoBuilder toBuilder() =>
      RecalculateWeeklyMoodStatsDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RecalculateWeeklyMoodStatsDto &&
        from == other.from &&
        to == other.to &&
        timezone == other.timezone;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, from.hashCode);
    _$hash = $jc(_$hash, to.hashCode);
    _$hash = $jc(_$hash, timezone.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RecalculateWeeklyMoodStatsDto')
          ..add('from', from)
          ..add('to', to)
          ..add('timezone', timezone))
        .toString();
  }
}

class RecalculateWeeklyMoodStatsDtoBuilder
    implements
        Builder<RecalculateWeeklyMoodStatsDto,
            RecalculateWeeklyMoodStatsDtoBuilder> {
  _$RecalculateWeeklyMoodStatsDto? _$v;

  DateTime? _from;
  DateTime? get from => _$this._from;
  set from(DateTime? from) => _$this._from = from;

  DateTime? _to;
  DateTime? get to => _$this._to;
  set to(DateTime? to) => _$this._to = to;

  String? _timezone;
  String? get timezone => _$this._timezone;
  set timezone(String? timezone) => _$this._timezone = timezone;

  RecalculateWeeklyMoodStatsDtoBuilder() {
    RecalculateWeeklyMoodStatsDto._defaults(this);
  }

  RecalculateWeeklyMoodStatsDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _from = $v.from;
      _to = $v.to;
      _timezone = $v.timezone;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RecalculateWeeklyMoodStatsDto other) {
    _$v = other as _$RecalculateWeeklyMoodStatsDto;
  }

  @override
  void update(void Function(RecalculateWeeklyMoodStatsDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RecalculateWeeklyMoodStatsDto build() => _build();

  _$RecalculateWeeklyMoodStatsDto _build() {
    final _$result = _$v ??
        _$RecalculateWeeklyMoodStatsDto._(
          from: from,
          to: to,
          timezone: timezone,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
