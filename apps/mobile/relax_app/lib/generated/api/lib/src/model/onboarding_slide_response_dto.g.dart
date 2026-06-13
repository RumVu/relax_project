// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_slide_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OnboardingSlideResponseDto extends OnboardingSlideResponseDto {
  @override
  final String id;
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
  final num displayOrder;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$OnboardingSlideResponseDto(
          [void Function(OnboardingSlideResponseDtoBuilder)? updates]) =>
      (OnboardingSlideResponseDtoBuilder()..update(updates))._build();

  _$OnboardingSlideResponseDto._(
      {required this.id,
      required this.title,
      this.subtitle,
      this.description,
      this.imageUrl,
      this.animationUrl,
      required this.displayOrder,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  OnboardingSlideResponseDto rebuild(
          void Function(OnboardingSlideResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OnboardingSlideResponseDtoBuilder toBuilder() =>
      OnboardingSlideResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OnboardingSlideResponseDto &&
        id == other.id &&
        title == other.title &&
        subtitle == other.subtitle &&
        description == other.description &&
        imageUrl == other.imageUrl &&
        animationUrl == other.animationUrl &&
        displayOrder == other.displayOrder &&
        isActive == other.isActive &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, subtitle.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, animationUrl.hashCode);
    _$hash = $jc(_$hash, displayOrder.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OnboardingSlideResponseDto')
          ..add('id', id)
          ..add('title', title)
          ..add('subtitle', subtitle)
          ..add('description', description)
          ..add('imageUrl', imageUrl)
          ..add('animationUrl', animationUrl)
          ..add('displayOrder', displayOrder)
          ..add('isActive', isActive)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class OnboardingSlideResponseDtoBuilder
    implements
        Builder<OnboardingSlideResponseDto, OnboardingSlideResponseDtoBuilder> {
  _$OnboardingSlideResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

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

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  OnboardingSlideResponseDtoBuilder() {
    OnboardingSlideResponseDto._defaults(this);
  }

  OnboardingSlideResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _title = $v.title;
      _subtitle = $v.subtitle;
      _description = $v.description;
      _imageUrl = $v.imageUrl;
      _animationUrl = $v.animationUrl;
      _displayOrder = $v.displayOrder;
      _isActive = $v.isActive;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OnboardingSlideResponseDto other) {
    _$v = other as _$OnboardingSlideResponseDto;
  }

  @override
  void update(void Function(OnboardingSlideResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OnboardingSlideResponseDto build() => _build();

  _$OnboardingSlideResponseDto _build() {
    final _$result = _$v ??
        _$OnboardingSlideResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'OnboardingSlideResponseDto', 'id'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'OnboardingSlideResponseDto', 'title'),
          subtitle: subtitle,
          description: description,
          imageUrl: imageUrl,
          animationUrl: animationUrl,
          displayOrder: BuiltValueNullFieldError.checkNotNull(
              displayOrder, r'OnboardingSlideResponseDto', 'displayOrder'),
          isActive: BuiltValueNullFieldError.checkNotNull(
              isActive, r'OnboardingSlideResponseDto', 'isActive'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'OnboardingSlideResponseDto', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'OnboardingSlideResponseDto', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
