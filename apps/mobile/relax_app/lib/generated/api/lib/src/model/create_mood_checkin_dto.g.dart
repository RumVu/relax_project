// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_mood_checkin_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateMoodCheckinDto extends CreateMoodCheckinDto {
  @override
  final JsonObject mood;
  @override
  final num? intensity;
  @override
  final String? note;
  @override
  final BuiltList<String>? tags;
  @override
  final JsonObject? trigger;

  factory _$CreateMoodCheckinDto(
          [void Function(CreateMoodCheckinDtoBuilder)? updates]) =>
      (CreateMoodCheckinDtoBuilder()..update(updates))._build();

  _$CreateMoodCheckinDto._(
      {required this.mood, this.intensity, this.note, this.tags, this.trigger})
      : super._();
  @override
  CreateMoodCheckinDto rebuild(
          void Function(CreateMoodCheckinDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateMoodCheckinDtoBuilder toBuilder() =>
      CreateMoodCheckinDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateMoodCheckinDto &&
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
    return (newBuiltValueToStringHelper(r'CreateMoodCheckinDto')
          ..add('mood', mood)
          ..add('intensity', intensity)
          ..add('note', note)
          ..add('tags', tags)
          ..add('trigger', trigger))
        .toString();
  }
}

class CreateMoodCheckinDtoBuilder
    implements Builder<CreateMoodCheckinDto, CreateMoodCheckinDtoBuilder> {
  _$CreateMoodCheckinDto? _$v;

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

  CreateMoodCheckinDtoBuilder() {
    CreateMoodCheckinDto._defaults(this);
  }

  CreateMoodCheckinDtoBuilder get _$this {
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
  void replace(CreateMoodCheckinDto other) {
    _$v = other as _$CreateMoodCheckinDto;
  }

  @override
  void update(void Function(CreateMoodCheckinDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateMoodCheckinDto build() => _build();

  _$CreateMoodCheckinDto _build() {
    _$CreateMoodCheckinDto _$result;
    try {
      _$result = _$v ??
          _$CreateMoodCheckinDto._(
            mood: BuiltValueNullFieldError.checkNotNull(
                mood, r'CreateMoodCheckinDto', 'mood'),
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
            r'CreateMoodCheckinDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
