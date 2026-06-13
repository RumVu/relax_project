// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rate_content_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RateContentDto extends RateContentDto {
  @override
  final String contentType;
  @override
  final String contentId;
  @override
  final num rating;
  @override
  final String? review;

  factory _$RateContentDto([void Function(RateContentDtoBuilder)? updates]) =>
      (RateContentDtoBuilder()..update(updates))._build();

  _$RateContentDto._(
      {required this.contentType,
      required this.contentId,
      required this.rating,
      this.review})
      : super._();
  @override
  RateContentDto rebuild(void Function(RateContentDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RateContentDtoBuilder toBuilder() => RateContentDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RateContentDto &&
        contentType == other.contentType &&
        contentId == other.contentId &&
        rating == other.rating &&
        review == other.review;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, contentType.hashCode);
    _$hash = $jc(_$hash, contentId.hashCode);
    _$hash = $jc(_$hash, rating.hashCode);
    _$hash = $jc(_$hash, review.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RateContentDto')
          ..add('contentType', contentType)
          ..add('contentId', contentId)
          ..add('rating', rating)
          ..add('review', review))
        .toString();
  }
}

class RateContentDtoBuilder
    implements Builder<RateContentDto, RateContentDtoBuilder> {
  _$RateContentDto? _$v;

  String? _contentType;
  String? get contentType => _$this._contentType;
  set contentType(String? contentType) => _$this._contentType = contentType;

  String? _contentId;
  String? get contentId => _$this._contentId;
  set contentId(String? contentId) => _$this._contentId = contentId;

  num? _rating;
  num? get rating => _$this._rating;
  set rating(num? rating) => _$this._rating = rating;

  String? _review;
  String? get review => _$this._review;
  set review(String? review) => _$this._review = review;

  RateContentDtoBuilder() {
    RateContentDto._defaults(this);
  }

  RateContentDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _contentType = $v.contentType;
      _contentId = $v.contentId;
      _rating = $v.rating;
      _review = $v.review;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RateContentDto other) {
    _$v = other as _$RateContentDto;
  }

  @override
  void update(void Function(RateContentDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RateContentDto build() => _build();

  _$RateContentDto _build() {
    final _$result = _$v ??
        _$RateContentDto._(
          contentType: BuiltValueNullFieldError.checkNotNull(
              contentType, r'RateContentDto', 'contentType'),
          contentId: BuiltValueNullFieldError.checkNotNull(
              contentId, r'RateContentDto', 'contentId'),
          rating: BuiltValueNullFieldError.checkNotNull(
              rating, r'RateContentDto', 'rating'),
          review: review,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
