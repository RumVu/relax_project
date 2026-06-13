// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breathing_exercise_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BreathingExerciseResponseDto extends BreathingExerciseResponseDto {
  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final num inhaleSeconds;
  @override
  final num holdSeconds;
  @override
  final num exhaleSeconds;
  @override
  final num cycles;
  @override
  final num? duration;
  @override
  final String? imageUrl;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$BreathingExerciseResponseDto(
          [void Function(BreathingExerciseResponseDtoBuilder)? updates]) =>
      (BreathingExerciseResponseDtoBuilder()..update(updates))._build();

  _$BreathingExerciseResponseDto._(
      {required this.id,
      required this.title,
      this.description,
      required this.inhaleSeconds,
      required this.holdSeconds,
      required this.exhaleSeconds,
      required this.cycles,
      this.duration,
      this.imageUrl,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  BreathingExerciseResponseDto rebuild(
          void Function(BreathingExerciseResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BreathingExerciseResponseDtoBuilder toBuilder() =>
      BreathingExerciseResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BreathingExerciseResponseDto &&
        id == other.id &&
        title == other.title &&
        description == other.description &&
        inhaleSeconds == other.inhaleSeconds &&
        holdSeconds == other.holdSeconds &&
        exhaleSeconds == other.exhaleSeconds &&
        cycles == other.cycles &&
        duration == other.duration &&
        imageUrl == other.imageUrl &&
        isActive == other.isActive &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, inhaleSeconds.hashCode);
    _$hash = $jc(_$hash, holdSeconds.hashCode);
    _$hash = $jc(_$hash, exhaleSeconds.hashCode);
    _$hash = $jc(_$hash, cycles.hashCode);
    _$hash = $jc(_$hash, duration.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BreathingExerciseResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('description', description)
          ..add('inhaleSeconds', inhaleSeconds)
          ..add('holdSeconds', holdSeconds)
          ..add('exhaleSeconds', exhaleSeconds)
          ..add('cycles', cycles)
          ..add('duration', duration)
          ..add('imageUrl', imageUrl)
          ..add('isActive', isActive)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class BreathingExerciseResponseDtoBuilder
    implements
        Builder<BreathingExerciseResponseDto,
            BreathingExerciseResponseDtoBuilder> {
  _$BreathingExerciseResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  num? _inhaleSeconds;
  num? get inhaleSeconds => _$this._inhaleSeconds;
  set inhaleSeconds(num? inhaleSeconds) =>
      _$this._inhaleSeconds = inhaleSeconds;

  num? _holdSeconds;
  num? get holdSeconds => _$this._holdSeconds;
  set holdSeconds(num? holdSeconds) => _$this._holdSeconds = holdSeconds;

  num? _exhaleSeconds;
  num? get exhaleSeconds => _$this._exhaleSeconds;
  set exhaleSeconds(num? exhaleSeconds) =>
      _$this._exhaleSeconds = exhaleSeconds;

  num? _cycles;
  num? get cycles => _$this._cycles;
  set cycles(num? cycles) => _$this._cycles = cycles;

  num? _duration;
  num? get duration => _$this._duration;
  set duration(num? duration) => _$this._duration = duration;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(String? imageUrl) => _$this._imageUrl = imageUrl;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  BreathingExerciseResponseDtoBuilder() {
    BreathingExerciseResponseDto._defaults(this);
  }

  BreathingExerciseResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _description = $v.description;
      _inhaleSeconds = $v.inhaleSeconds;
      _holdSeconds = $v.holdSeconds;
      _exhaleSeconds = $v.exhaleSeconds;
      _cycles = $v.cycles;
      _duration = $v.duration;
      _imageUrl = $v.imageUrl;
      _isActive = $v.isActive;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BreathingExerciseResponseDto other) {
    _$v = other as _$BreathingExerciseResponseDto;
  }

  @override
  void update(void Function(BreathingExerciseResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BreathingExerciseResponseDto build() => _build();

  _$BreathingExerciseResponseDto _build() {
    final _$result = _$v ??
        _$BreathingExerciseResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'BreathingExerciseResponseDto', 'id'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'BreathingExerciseResponseDto', 'title'),
          description: description,
          inhaleSeconds: BuiltValueNullFieldError.checkNotNull(
              inhaleSeconds, r'BreathingExerciseResponseDto', 'inhaleSeconds'),
          holdSeconds: BuiltValueNullFieldError.checkNotNull(
              holdSeconds, r'BreathingExerciseResponseDto', 'holdSeconds'),
          exhaleSeconds: BuiltValueNullFieldError.checkNotNull(
              exhaleSeconds, r'BreathingExerciseResponseDto', 'exhaleSeconds'),
          cycles: BuiltValueNullFieldError.checkNotNull(
              cycles, r'BreathingExerciseResponseDto', 'cycles'),
          duration: duration,
          imageUrl: imageUrl,
          isActive: BuiltValueNullFieldError.checkNotNull(
              isActive, r'BreathingExerciseResponseDto', 'isActive'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'BreathingExerciseResponseDto', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'BreathingExerciseResponseDto', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
