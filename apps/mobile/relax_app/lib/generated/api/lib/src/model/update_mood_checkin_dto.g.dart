// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_mood_checkin_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateMoodCheckinDto extends UpdateMoodCheckinDto {
  @override
  final JsonObject? mood;
  @override
  final num? intensity;
  @override
  final String? note;
  @override
  final BuiltList<String>? tags;
  @override
  final JsonObject? trigger;

  factory _$UpdateMoodCheckinDto(
          [void Function(UpdateMoodCheckinDtoBuilder)? updates]) =>
      (UpdateMoodCheckinDtoBuilder()..update(updates))._build();

  _$UpdateMoodCheckinDto._(
      {this.mood, this.intensity, this.note, this.tags, this.trigger})
      : super._();
  @override
  UpdateMoodCheckinDto rebuild(
          void Function(UpdateMoodCheckinDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateMoodCheckinDtoBuilder toBuilder() =>
      UpdateMoodCheckinDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateMoodCheckinDto &&
        mood == other.mood &&
        intensity == other.intensity &&
        note == other.note &&
        tags == other.tags &&
        trigger == other.trigger;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mood.hashCode);
    _$hash = $jc(_$hash, intensity.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, tags.hashCode);
    _$hash = $jc(_$hash, trigger.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateMoodCheckinDto')
          ..add('mood', mood)
          ..add('intensity', intensity)
          ..add('note', note)
          ..add('tags', tags)
          ..add('trigger', trigger))
        .toString();
  }
}

class UpdateMoodCheckinDtoBuilder
    implements Builder<UpdateMoodCheckinDto, UpdateMoodCheckinDtoBuilder> {
  _$UpdateMoodCheckinDto? _$v;

  JsonObject? _mood;
  JsonObject? get mood => _$this._mood;
  set mood(JsonObject? mood) => _$this._mood = mood;

  num? _intensity;
  num? get intensity => _$this._intensity;
  set intensity(num? intensity) => _$this._intensity = intensity;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  ListBuilder<String>? _tags;
  ListBuilder<String> get tags => _$this._tags ??= ListBuilder<String>();
  set tags(ListBuilder<String>? tags) => _$this._tags = tags;

  JsonObject? _trigger;
  JsonObject? get trigger => _$this._trigger;
  set trigger(JsonObject? trigger) => _$this._trigger = trigger;

  UpdateMoodCheckinDtoBuilder() {
    UpdateMoodCheckinDto._defaults(this);
  }

  UpdateMoodCheckinDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mood = $v.mood;
      _intensity = $v.intensity;
      _note = $v.note;
      _tags = $v.tags?.toBuilder();
      _trigger = $v.trigger;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateMoodCheckinDto other) {
    _$v = other as _$UpdateMoodCheckinDto;
  }

  @override
  void update(void Function(UpdateMoodCheckinDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateMoodCheckinDto build() => _build();

  _$UpdateMoodCheckinDto _build() {
    _$UpdateMoodCheckinDto _$result;
    try {
      _$result = _$v ??
          _$UpdateMoodCheckinDto._(
            mood: mood,
            intensity: intensity,
            note: note,
            tags: _tags?.build(),
            trigger: trigger,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tags';
        _tags?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UpdateMoodCheckinDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
