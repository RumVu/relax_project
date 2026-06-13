// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_ambient_sound_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateAmbientSoundDto extends UpdateAmbientSoundDto {
  @override
  final String? title;
  @override
  final String? description;
  @override
  final String? category;
  @override
  final String? soundUrl;
  @override
  final String? imageUrl;
  @override
  final num? duration;
  @override
  final bool? isActive;

  factory _$UpdateAmbientSoundDto(
          [void Function(UpdateAmbientSoundDtoBuilder)? updates]) =>
      (UpdateAmbientSoundDtoBuilder()..update(updates))._build();

  _$UpdateAmbientSoundDto._(
      {this.title,
      this.description,
      this.category,
      this.soundUrl,
      this.imageUrl,
      this.duration,
      this.isActive})
      : super._();
  @override
  UpdateAmbientSoundDto rebuild(
          void Function(UpdateAmbientSoundDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateAmbientSoundDtoBuilder toBuilder() =>
      UpdateAmbientSoundDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateAmbientSoundDto &&
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
    return (newBuiltValueToStringHelper(r'UpdateAmbientSoundDto')
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

class UpdateAmbientSoundDtoBuilder
    implements Builder<UpdateAmbientSoundDto, UpdateAmbientSoundDtoBuilder> {
  _$UpdateAmbientSoundDto? _$v;

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

  UpdateAmbientSoundDtoBuilder() {
    UpdateAmbientSoundDto._defaults(this);
  }

  UpdateAmbientSoundDtoBuilder get _$this {
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
  void replace(UpdateAmbientSoundDto other) {
    _$v = other as _$UpdateAmbientSoundDto;
  }

  @override
  void update(void Function(UpdateAmbientSoundDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateAmbientSoundDto build() => _build();

  _$UpdateAmbientSoundDto _build() {
    final _$result = _$v ??
        _$UpdateAmbientSoundDto._(
          title: title,
          description: description,
          category: category,
          soundUrl: soundUrl,
          imageUrl: imageUrl,
          duration: duration,
          isActive: isActive,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
