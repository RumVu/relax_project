// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ambient_sound_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AmbientSoundResponseDto extends AmbientSoundResponseDto {
  @override
  final String id;
  @override
  final String title;
  @override
  final String? description;
  @override
  final String category;
  @override
  final String soundUrl;
  @override
  final String? imageUrl;
  @override
  final num? duration;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$AmbientSoundResponseDto(
          [void Function(AmbientSoundResponseDtoBuilder)? updates]) =>
      (AmbientSoundResponseDtoBuilder()..update(updates))._build();

  _$AmbientSoundResponseDto._(
      {required this.id,
      required this.title,
      this.description,
      required this.category,
      required this.soundUrl,
      this.imageUrl,
      this.duration,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  AmbientSoundResponseDto rebuild(
          void Function(AmbientSoundResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AmbientSoundResponseDtoBuilder toBuilder() =>
      AmbientSoundResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AmbientSoundResponseDto &&
        id == other.id &&
        title == other.title &&
        description == other.description &&
        category == other.category &&
        soundUrl == other.soundUrl &&
        imageUrl == other.imageUrl &&
        duration == other.duration &&
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
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, soundUrl.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, duration.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AmbientSoundResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('description', description)
          ..add('category', category)
          ..add('soundUrl', soundUrl)
          ..add('imageUrl', imageUrl)
          ..add('duration', duration)
          ..add('isActive', isActive)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class AmbientSoundResponseDtoBuilder
    implements
        Builder<AmbientSoundResponseDto, AmbientSoundResponseDtoBuilder> {
  _$AmbientSoundResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _category;
  String? get category => _$this._category;
  set category(String? category) => _$this._category = category;

  String? _soundUrl;
  String? get soundUrl => _$this._soundUrl;
  set soundUrl(String? soundUrl) => _$this._soundUrl = soundUrl;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(String? imageUrl) => _$this._imageUrl = imageUrl;

  num? _duration;
  num? get duration => _$this._duration;
  set duration(num? duration) => _$this._duration = duration;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  AmbientSoundResponseDtoBuilder() {
    AmbientSoundResponseDto._defaults(this);
  }

  AmbientSoundResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _description = $v.description;
      _category = $v.category;
      _soundUrl = $v.soundUrl;
      _imageUrl = $v.imageUrl;
      _duration = $v.duration;
      _isActive = $v.isActive;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AmbientSoundResponseDto other) {
    _$v = other as _$AmbientSoundResponseDto;
  }

  @override
  void update(void Function(AmbientSoundResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AmbientSoundResponseDto build() => _build();

  _$AmbientSoundResponseDto _build() {
    final _$result = _$v ??
        _$AmbientSoundResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'AmbientSoundResponseDto', 'id'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'AmbientSoundResponseDto', 'title'),
          description: description,
          category: BuiltValueNullFieldError.checkNotNull(
              category, r'AmbientSoundResponseDto', 'category'),
          soundUrl: BuiltValueNullFieldError.checkNotNull(
              soundUrl, r'AmbientSoundResponseDto', 'soundUrl'),
          imageUrl: imageUrl,
          duration: duration,
          isActive: BuiltValueNullFieldError.checkNotNull(
              isActive, r'AmbientSoundResponseDto', 'isActive'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'AmbientSoundResponseDto', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'AmbientSoundResponseDto', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
