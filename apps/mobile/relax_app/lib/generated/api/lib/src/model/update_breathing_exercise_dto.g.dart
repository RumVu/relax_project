// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_breathing_exercise_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateBreathingExerciseDto extends UpdateBreathingExerciseDto {
  @override
  final String? title;
  @override
  final String? description;
  @override
  final num? inhaleSeconds;
  @override
  final num? holdSeconds;
  @override
  final num? exhaleSeconds;
  @override
  final num? cycles;
  @override
  final num? duration;
  @override
  final String? imageUrl;
  @override
  final bool? isActive;

  factory _$UpdateBreathingExerciseDto(
          [void Function(UpdateBreathingExerciseDtoBuilder)? updates]) =>
      (UpdateBreathingExerciseDtoBuilder()..update(updates))._build();

  _$UpdateBreathingExerciseDto._(
      {this.title,
      this.description,
      this.inhaleSeconds,
      this.holdSeconds,
      this.exhaleSeconds,
      this.cycles,
      this.duration,
      this.imageUrl,
      this.isActive})
      : super._();
  @override
  UpdateBreathingExerciseDto rebuild(
          void Function(UpdateBreathingExerciseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateBreathingExerciseDtoBuilder toBuilder() =>
      UpdateBreathingExerciseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateBreathingExerciseDto &&
        title == other.title &&
        description == other.description &&
        inhaleSeconds == other.inhaleSeconds &&
        holdSeconds == other.holdSeconds &&
        exhaleSeconds == other.exhaleSeconds &&
        cycles == other.cycles &&
        duration == other.duration &&
        imageUrl == other.imageUrl &&
        isActive == other.isActive;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, inhaleSeconds.hashCode);
    _$hash = $jc(_$hash, holdSeconds.hashCode);
    _$hash = $jc(_$hash, exhaleSeconds.hashCode);
    _$hash = $jc(_$hash, cycles.hashCode);
    _$hash = $jc(_$hash, duration.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateBreathingExerciseDto')
          ..add('title', title)
          ..add('description', description)
          ..add('inhaleSeconds', inhaleSeconds)
          ..add('holdSeconds', holdSeconds)
          ..add('exhaleSeconds', exhaleSeconds)
          ..add('cycles', cycles)
          ..add('duration', duration)
          ..add('imageUrl', imageUrl)
          ..add('isActive', isActive))
        .toString();
  }
}

class UpdateBreathingExerciseDtoBuilder
    implements
        Builder<UpdateBreathingExerciseDto, UpdateBreathingExerciseDtoBuilder> {
  _$UpdateBreathingExerciseDto? _$v;

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

  UpdateBreathingExerciseDtoBuilder() {
    UpdateBreathingExerciseDto._defaults(this);
  }

  UpdateBreathingExerciseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _description = $v.description;
      _inhaleSeconds = $v.inhaleSeconds;
      _holdSeconds = $v.holdSeconds;
      _exhaleSeconds = $v.exhaleSeconds;
      _cycles = $v.cycles;
      _duration = $v.duration;
      _imageUrl = $v.imageUrl;
      _isActive = $v.isActive;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateBreathingExerciseDto other) {
    _$v = other as _$UpdateBreathingExerciseDto;
  }

  @override
  void update(void Function(UpdateBreathingExerciseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateBreathingExerciseDto build() => _build();

  _$UpdateBreathingExerciseDto _build() {
    final _$result = _$v ??
        _$UpdateBreathingExerciseDto._(
          title: title,
          description: description,
          inhaleSeconds: inhaleSeconds,
          holdSeconds: holdSeconds,
          exhaleSeconds: exhaleSeconds,
          cycles: cycles,
          duration: duration,
          imageUrl: imageUrl,
          isActive: isActive,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
