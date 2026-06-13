// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companion_message_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CompanionMessageResponseDto extends CompanionMessageResponseDto {
  @override
  final String id;
  @override
  final String content;
  @override
  final JsonObject triggerType;
  @override
  final JsonObject? mood;
  @override
  final JsonObject? companionMood;
  @override
  final num? minHour;
  @override
  final num? maxHour;
  @override
  final num weight;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$CompanionMessageResponseDto(
          [void Function(CompanionMessageResponseDtoBuilder)? updates]) =>
      (CompanionMessageResponseDtoBuilder()..update(updates))._build();

  _$CompanionMessageResponseDto._(
      {required this.id,
      required this.content,
      required this.triggerType,
      this.mood,
      this.companionMood,
      this.minHour,
      this.maxHour,
      required this.weight,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  CompanionMessageResponseDto rebuild(
          void Function(CompanionMessageResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CompanionMessageResponseDtoBuilder toBuilder() =>
      CompanionMessageResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompanionMessageResponseDto &&
        id == other.id &&
        content == other.content &&
        triggerType == other.triggerType &&
        mood == other.mood &&
        companionMood == other.companionMood &&
        minHour == other.minHour &&
        maxHour == other.maxHour &&
        weight == other.weight &&
        isActive == other.isActive &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, triggerType.hashCode);
    _$hash = $jc(_$hash, mood.hashCode);
    _$hash = $jc(_$hash, companionMood.hashCode);
    _$hash = $jc(_$hash, minHour.hashCode);
    _$hash = $jc(_$hash, maxHour.hashCode);
    _$hash = $jc(_$hash, weight.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CompanionMessageResponseDto')
          ..add('id', id)
          ..add('content', content)
          ..add('triggerType', triggerType)
          ..add('mood', mood)
          ..add('companionMood', companionMood)
          ..add('minHour', minHour)
          ..add('maxHour', maxHour)
          ..add('weight', weight)
          ..add('isActive', isActive)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class CompanionMessageResponseDtoBuilder
    implements
        Builder<CompanionMessageResponseDto,
            CompanionMessageResponseDtoBuilder> {
  _$CompanionMessageResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

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

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  CompanionMessageResponseDtoBuilder() {
    CompanionMessageResponseDto._defaults(this);
  }

  CompanionMessageResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _content = $v.content;
      _triggerType = $v.triggerType;
      _mood = $v.mood;
      _companionMood = $v.companionMood;
      _minHour = $v.minHour;
      _maxHour = $v.maxHour;
      _weight = $v.weight;
      _isActive = $v.isActive;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CompanionMessageResponseDto other) {
    _$v = other as _$CompanionMessageResponseDto;
  }

  @override
  void update(void Function(CompanionMessageResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CompanionMessageResponseDto build() => _build();

  _$CompanionMessageResponseDto _build() {
    final _$result = _$v ??
        _$CompanionMessageResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'CompanionMessageResponseDto', 'id'),
          content: BuiltValueNullFieldError.checkNotNull(
              content, r'CompanionMessageResponseDto', 'content'),
          triggerType: BuiltValueNullFieldError.checkNotNull(
              triggerType, r'CompanionMessageResponseDto', 'triggerType'),
          mood: mood,
          companionMood: companionMood,
          minHour: minHour,
          maxHour: maxHour,
          weight: BuiltValueNullFieldError.checkNotNull(
              weight, r'CompanionMessageResponseDto', 'weight'),
          isActive: BuiltValueNullFieldError.checkNotNull(
              isActive, r'CompanionMessageResponseDto', 'isActive'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'CompanionMessageResponseDto', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'CompanionMessageResponseDto', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
