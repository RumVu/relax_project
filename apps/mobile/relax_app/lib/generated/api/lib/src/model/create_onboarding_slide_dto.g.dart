// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_onboarding_slide_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateOnboardingSlideDto extends CreateOnboardingSlideDto {
  @override
  final String title;
  @override
  final String? subtitle;
  @override
  final String? description;
  @override
  final String? imageUrl;
  @override
  final String? animationUrl;
  @override
  final num? displayOrder;
  @override
  final bool? isActive;

  factory _$CreateOnboardingSlideDto(
          [void Function(CreateOnboardingSlideDtoBuilder)? updates]) =>
      (CreateOnboardingSlideDtoBuilder()..update(updates))._build();

  _$CreateOnboardingSlideDto._(
      {required this.title,
      this.subtitle,
      this.description,
      this.imageUrl,
      this.animationUrl,
      this.displayOrder,
      this.isActive})
      : super._();
  @override
  CreateOnboardingSlideDto rebuild(
          void Function(CreateOnboardingSlideDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateOnboardingSlideDtoBuilder toBuilder() =>
      CreateOnboardingSlideDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateOnboardingSlideDto &&
        title == other.title &&
        subtitle == other.subtitle &&
        description == other.description &&
        imageUrl == other.imageUrl &&
        animationUrl == other.animationUrl &&
        displayOrder == other.displayOrder &&
        isActive == other.isActive;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, subtitle.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, animationUrl.hashCode);
    _$hash = $jc(_$hash, displayOrder.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateOnboardingSlideDto')
          ..add('title', title)
          ..add('subtitle', subtitle)
          ..add('description', description)
          ..add('imageUrl', imageUrl)
          ..add('animationUrl', animationUrl)
          ..add('displayOrder', displayOrder)
          ..add('isActive', isActive))
        .toString();
  }
}

class CreateOnboardingSlideDtoBuilder
    implements
        Builder<CreateOnboardingSlideDto, CreateOnboardingSlideDtoBuilder> {
  _$CreateOnboardingSlideDto? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _subtitle;
  String? get subtitle => _$this._subtitle;
  set subtitle(String? subtitle) => _$this._subtitle = subtitle;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(String? imageUrl) => _$this._imageUrl = imageUrl;

  String? _animationUrl;
  String? get animationUrl => _$this._animationUrl;
  set animationUrl(String? animationUrl) => _$this._animationUrl = animationUrl;

  num? _displayOrder;
  num? get displayOrder => _$this._displayOrder;
  set displayOrder(num? displayOrder) => _$this._displayOrder = displayOrder;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  CreateOnboardingSlideDtoBuilder() {
    CreateOnboardingSlideDto._defaults(this);
  }

  CreateOnboardingSlideDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _subtitle = $v.subtitle;
      _description = $v.description;
      _imageUrl = $v.imageUrl;
      _animationUrl = $v.animationUrl;
      _displayOrder = $v.displayOrder;
      _isActive = $v.isActive;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateOnboardingSlideDto other) {
    _$v = other as _$CreateOnboardingSlideDto;
  }

  @override
  void update(void Function(CreateOnboardingSlideDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateOnboardingSlideDto build() => _build();

  _$CreateOnboardingSlideDto _build() {
    final _$result = _$v ??
        _$CreateOnboardingSlideDto._(
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'CreateOnboardingSlideDto', 'title'),
          subtitle: subtitle,
          description: description,
          imageUrl: imageUrl,
          animationUrl: animationUrl,
          displayOrder: displayOrder,
          isActive: isActive,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
