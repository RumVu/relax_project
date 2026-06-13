// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_companion_message_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateCompanionMessageDto extends UpdateCompanionMessageDto {
  @override
  final String? content;
  @override
  final JsonObject? triggerType;
  @override
  final JsonObject? mood;
  @override
  final JsonObject? companionMood;
  @override
  final num? minHour;
  @override
  final num? maxHour;
  @override
  final num? weight;
  @override
  final bool? isActive;

  factory _$UpdateCompanionMessageDto(
          [void Function(UpdateCompanionMessageDtoBuilder)? updates]) =>
      (UpdateCompanionMessageDtoBuilder()..update(updates))._build();

  _$UpdateCompanionMessageDto._(
      {this.content,
      this.triggerType,
      this.mood,
      this.companionMood,
      this.minHour,
      this.maxHour,
      this.weight,
      this.isActive})
      : super._();
  @override
  UpdateCompanionMessageDto rebuild(
          void Function(UpdateCompanionMessageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateCompanionMessageDtoBuilder toBuilder() =>
      UpdateCompanionMessageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateCompanionMessageDto &&
        content == other.content &&
        triggerType == other.triggerType &&
        mood == other.mood &&
        companionMood == other.companionMood &&
        minHour == other.minHour &&
        maxHour == other.maxHour &&
        weight == other.weight &&
        isActive == other.isActive;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, triggerType.hashCode);
    _$hash = $jc(_$hash, mood.hashCode);
    _$hash = $jc(_$hash, companionMood.hashCode);
    _$hash = $jc(_$hash, minHour.hashCode);
    _$hash = $jc(_$hash, maxHour.hashCode);
    _$hash = $jc(_$hash, weight.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateCompanionMessageDto')
          ..add('content', content)
          ..add('triggerType', triggerType)
          ..add('mood', mood)
          ..add('companionMood', companionMood)
          ..add('minHour', minHour)
          ..add('maxHour', maxHour)
          ..add('weight', weight)
          ..add('isActive', isActive))
        .toString();
  }
}

class UpdateCompanionMessageDtoBuilder
    implements
        Builder<UpdateCompanionMessageDto, UpdateCompanionMessageDtoBuilder> {
  _$UpdateCompanionMessageDto? _$v;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  JsonObject? _triggerType;
  JsonObject? get triggerType => _$this._triggerType;
  set triggerType(JsonObject? triggerType) => _$this._triggerType = triggerType;

  JsonObject? _mood;
  JsonObject? get mood => _$this._mood;
  set mood(JsonObject? mood) => _$this._mood = mood;

  JsonObject? _companionMood;
  JsonObject? get companionMood => _$this._companionMood;
  set companionMood(JsonObject? companionMood) =>
      _$this._companionMood = companionMood;

  num? _minHour;
  num? get minHour => _$this._minHour;
  set minHour(num? minHour) => _$this._minHour = minHour;

  num? _maxHour;
  num? get maxHour => _$this._maxHour;
  set maxHour(num? maxHour) => _$this._maxHour = maxHour;

  num? _weight;
  num? get weight => _$this._weight;
  set weight(num? weight) => _$this._weight = weight;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  UpdateCompanionMessageDtoBuilder() {
    UpdateCompanionMessageDto._defaults(this);
  }

  UpdateCompanionMessageDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
      _triggerType = $v.triggerType;
      _mood = $v.mood;
      _companionMood = $v.companionMood;
      _minHour = $v.minHour;
      _maxHour = $v.maxHour;
      _weight = $v.weight;
      _isActive = $v.isActive;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateCompanionMessageDto other) {
    _$v = other as _$UpdateCompanionMessageDto;
  }

  @override
  void update(void Function(UpdateCompanionMessageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateCompanionMessageDto build() => _build();

  _$UpdateCompanionMessageDto _build() {
    final _$result = _$v ??
        _$UpdateCompanionMessageDto._(
          content: content,
          triggerType: triggerType,
          mood: mood,
          companionMood: companionMood,
          minHour: minHour,
          maxHour: maxHour,
          weight: weight,
          isActive: isActive,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
