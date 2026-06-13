// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_ambient_sound_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateAmbientSoundDto extends CreateAmbientSoundDto {
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
  final bool? isActive;

  factory _$CreateAmbientSoundDto(
          [void Function(CreateAmbientSoundDtoBuilder)? updates]) =>
      (CreateAmbientSoundDtoBuilder()..update(updates))._build();

  _$CreateAmbientSoundDto._(
      {required this.title,
      this.description,
      required this.category,
      required this.soundUrl,
      this.imageUrl,
      this.duration,
      this.isActive})
      : super._();
  @override
  CreateAmbientSoundDto rebuild(
          void Function(CreateAmbientSoundDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateAmbientSoundDtoBuilder toBuilder() =>
      CreateAmbientSoundDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateAmbientSoundDto &&
        title == other.title &&
        description == other.description &&
        category == other.category &&
        soundUrl == other.soundUrl &&
        imageUrl == other.imageUrl &&
        duration == other.duration &&
        isActive == other.isActive;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, category.hashCode);
    _$hash = $jc(_$hash, soundUrl.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, duration.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateAmbientSoundDto')
          ..add('title', title)
          ..add('description', description)
          ..add('category', category)
          ..add('soundUrl', soundUrl)
          ..add('imageUrl', imageUrl)
          ..add('duration', duration)
          ..add('isActive', isActive))
        .toString();
  }
}

class CreateAmbientSoundDtoBuilder
    implements Builder<CreateAmbientSoundDto, CreateAmbientSoundDtoBuilder> {
  _$CreateAmbientSoundDto? _$v;

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

  CreateAmbientSoundDtoBuilder() {
    CreateAmbientSoundDto._defaults(this);
  }

  CreateAmbientSoundDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _description = $v.description;
      _category = $v.category;
      _soundUrl = $v.soundUrl;
      _imageUrl = $v.imageUrl;
      _duration = $v.duration;
      _isActive = $v.isActive;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateAmbientSoundDto other) {
    _$v = other as _$CreateAmbientSoundDto;
  }

  @override
  void update(void Function(CreateAmbientSoundDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateAmbientSoundDto build() => _build();

  _$CreateAmbientSoundDto _build() {
    final _$result = _$v ??
        _$CreateAmbientSoundDto._(
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'CreateAmbientSoundDto', 'title'),
          description: description,
          category: BuiltValueNullFieldError.checkNotNull(
              category, r'CreateAmbientSoundDto', 'category'),
          soundUrl: BuiltValueNullFieldError.checkNotNull(
              soundUrl, r'CreateAmbientSoundDto', 'soundUrl'),
          imageUrl: imageUrl,
          duration: duration,
          isActive: isActive,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
