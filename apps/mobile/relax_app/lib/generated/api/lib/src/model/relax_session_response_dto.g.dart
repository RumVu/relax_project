// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relax_session_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RelaxSessionResponseDto extends RelaxSessionResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final JsonObject activityType;
  @override
  final JsonObject status;
  @override
  final String? resourceId;
  @override
  final String title;
  @override
  final DateTime startedAt;
  @override
  final DateTime? endedAt;
  @override
  final num? duration;
  @override
  final JsonObject? moodBefore;
  @override
  final JsonObject? moodAfter;
  @override
  final num? reliefLevel;
  @override
  final num? stressReliefPercent;
  @override
  final String? note;
  @override
  final String? nextActionAccepted;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$RelaxSessionResponseDto(
          [void Function(RelaxSessionResponseDtoBuilder)? updates]) =>
      (RelaxSessionResponseDtoBuilder()..update(updates))._build();

  _$RelaxSessionResponseDto._(
      {required this.id,
      required this.userId,
      required this.activityType,
      required this.status,
      this.resourceId,
      required this.title,
      required this.startedAt,
      this.endedAt,
      this.duration,
      this.moodBefore,
      this.moodAfter,
      this.reliefLevel,
      this.stressReliefPercent,
      this.note,
      this.nextActionAccepted,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  RelaxSessionResponseDto rebuild(
          void Function(RelaxSessionResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RelaxSessionResponseDtoBuilder toBuilder() =>
      RelaxSessionResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RelaxSessionResponseDto &&
        id == other.id &&
        userId == other.userId &&
        activityType == other.activityType &&
        status == other.status &&
        resourceId == other.resourceId &&
        title == other.title &&
        startedAt == other.startedAt &&
        endedAt == other.endedAt &&
        duration == other.duration &&
        moodBefore == other.moodBefore &&
        moodAfter == other.moodAfter &&
        reliefLevel == other.reliefLevel &&
        stressReliefPercent == other.stressReliefPercent &&
        note == other.note &&
        nextActionAccepted == other.nextActionAccepted &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, activityType.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, startedAt.hashCode);
    _$hash = $jc(_$hash, endedAt.hashCode);
    _$hash = $jc(_$hash, duration.hashCode);
    _$hash = $jc(_$hash, moodBefore.hashCode);
    _$hash = $jc(_$hash, moodAfter.hashCode);
    _$hash = $jc(_$hash, reliefLevel.hashCode);
    _$hash = $jc(_$hash, stressReliefPercent.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, nextActionAccepted.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RelaxSessionResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('activityType', activityType)
          ..add('status', status)
          ..add('resourceId', resourceId)
          ..add('title', title)
          ..add('startedAt', startedAt)
          ..add('endedAt', endedAt)
          ..add('duration', duration)
          ..add('moodBefore', moodBefore)
          ..add('moodAfter', moodAfter)
          ..add('reliefLevel', reliefLevel)
          ..add('stressReliefPercent', stressReliefPercent)
          ..add('note', note)
          ..add('nextActionAccepted', nextActionAccepted)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class RelaxSessionResponseDtoBuilder
    implements
        Builder<RelaxSessionResponseDto, RelaxSessionResponseDtoBuilder> {
  _$RelaxSessionResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  JsonObject? _activityType;
  JsonObject? get activityType => _$this._activityType;
  set activityType(JsonObject? activityType) =>
      _$this._activityType = activityType;

  JsonObject? _status;
  JsonObject? get status => _$this._status;
  set status(JsonObject? status) => _$this._status = status;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  DateTime? _startedAt;
  DateTime? get startedAt => _$this._startedAt;
  set startedAt(DateTime? startedAt) => _$this._startedAt = startedAt;

  DateTime? _endedAt;
  DateTime? get endedAt => _$this._endedAt;
  set endedAt(DateTime? endedAt) => _$this._endedAt = endedAt;

  num? _duration;
  num? get duration => _$this._duration;
  set duration(num? duration) => _$this._duration = duration;

  JsonObject? _moodBefore;
  JsonObject? get moodBefore => _$this._moodBefore;
  set moodBefore(JsonObject? moodBefore) => _$this._moodBefore = moodBefore;

  JsonObject? _moodAfter;
  JsonObject? get moodAfter => _$this._moodAfter;
  set moodAfter(JsonObject? moodAfter) => _$this._moodAfter = moodAfter;

  num? _reliefLevel;
  num? get reliefLevel => _$this._reliefLevel;
  set reliefLevel(num? reliefLevel) => _$this._reliefLevel = reliefLevel;

  num? _stressReliefPercent;
  num? get stressReliefPercent => _$this._stressReliefPercent;
  set stressReliefPercent(num? stressReliefPercent) =>
      _$this._stressReliefPercent = stressReliefPercent;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  String? _nextActionAccepted;
  String? get nextActionAccepted => _$this._nextActionAccepted;
  set nextActionAccepted(String? nextActionAccepted) =>
      _$this._nextActionAccepted = nextActionAccepted;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  RelaxSessionResponseDtoBuilder() {
    RelaxSessionResponseDto._defaults(this);
  }

  RelaxSessionResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _activityType = $v.activityType;
      _status = $v.status;
      _resourceId = $v.resourceId;
      _title = $v.title;
      _startedAt = $v.startedAt;
      _endedAt = $v.endedAt;
      _duration = $v.duration;
      _moodBefore = $v.moodBefore;
      _moodAfter = $v.moodAfter;
      _reliefLevel = $v.reliefLevel;
      _stressReliefPercent = $v.stressReliefPercent;
      _note = $v.note;
      _nextActionAccepted = $v.nextActionAccepted;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RelaxSessionResponseDto other) {
    _$v = other as _$RelaxSessionResponseDto;
  }

  @override
  void update(void Function(RelaxSessionResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RelaxSessionResponseDto build() => _build();

  _$RelaxSessionResponseDto _build() {
    final _$result = _$v ??
        _$RelaxSessionResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'RelaxSessionResponseDto', 'id'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'RelaxSessionResponseDto', 'userId'),
          activityType: BuiltValueNullFieldError.checkNotNull(
              activityType, r'RelaxSessionResponseDto', 'activityType'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'RelaxSessionResponseDto', 'status'),
          resourceId: resourceId,
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'RelaxSessionResponseDto', 'title'),
          startedAt: BuiltValueNullFieldError.checkNotNull(
              startedAt, r'RelaxSessionResponseDto', 'startedAt'),
          endedAt: endedAt,
          duration: duration,
          moodBefore: moodBefore,
          moodAfter: moodAfter,
          reliefLevel: reliefLevel,
          stressReliefPercent: stressReliefPercent,
          note: note,
          nextActionAccepted: nextActionAccepted,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'RelaxSessionResponseDto', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'RelaxSessionResponseDto', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
