// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_slide_page_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$OnboardingSlidePageDto extends OnboardingSlidePageDto {
  @override
  final BuiltList<OnboardingSlideResponseDto> items;
  @override
  final num total;
  @override
  final num skip;
  @override
  final num limit;
  @override
  final bool hasMore;

  factory _$OnboardingSlidePageDto(
          [void Function(OnboardingSlidePageDtoBuilder)? updates]) =>
      (OnboardingSlidePageDtoBuilder()..update(updates))._build();

  _$OnboardingSlidePageDto._(
      {required this.items,
      required this.total,
      required this.skip,
      required this.limit,
      required this.hasMore})
      : super._();
  @override
  OnboardingSlidePageDto rebuild(
          void Function(OnboardingSlidePageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  OnboardingSlidePageDtoBuilder toBuilder() =>
      OnboardingSlidePageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is OnboardingSlidePageDto &&
        items == other.items &&
        total == other.total &&
        skip == other.skip &&
        limit == other.limit &&
        hasMore == other.hasMore;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jc(_$hash, total.hashCode);
    _$hash = $jc(_$hash, skip.hashCode);
    _$hash = $jc(_$hash, limit.hashCode);
    _$hash = $jc(_$hash, hasMore.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'OnboardingSlidePageDto')
          ..add('items', items)
          ..add('total', total)
          ..add('skip', skip)
          ..add('limit', limit)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class OnboardingSlidePageDtoBuilder
    implements Builder<OnboardingSlidePageDto, OnboardingSlidePageDtoBuilder> {
  _$OnboardingSlidePageDto? _$v;

  ListBuilder<OnboardingSlideResponseDto>? _items;
  ListBuilder<OnboardingSlideResponseDto> get items =>
      _$this._items ??= ListBuilder<OnboardingSlideResponseDto>();
  set items(ListBuilder<OnboardingSlideResponseDto>? items) =>
      _$this._items = items;

  num? _total;
  num? get total => _$this._total;
  set total(num? total) => _$this._total = total;

  num? _skip;
  num? get skip => _$this._skip;
  set skip(num? skip) => _$this._skip = skip;

  num? _limit;
  num? get limit => _$this._limit;
  set limit(num? limit) => _$this._limit = limit;

  bool? _hasMore;
  bool? get hasMore => _$this._hasMore;
  set hasMore(bool? hasMore) => _$this._hasMore = hasMore;

  OnboardingSlidePageDtoBuilder() {
    OnboardingSlidePageDto._defaults(this);
  }

  OnboardingSlidePageDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items.toBuilder();
      _total = $v.total;
      _skip = $v.skip;
      _limit = $v.limit;
      _hasMore = $v.hasMore;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(OnboardingSlidePageDto other) {
    _$v = other as _$OnboardingSlidePageDto;
  }

  @override
  void update(void Function(OnboardingSlidePageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  OnboardingSlidePageDto build() => _build();

  _$OnboardingSlidePageDto _build() {
    _$OnboardingSlidePageDto _$result;
    try {
      _$result = _$v ??
          _$OnboardingSlidePageDto._(
            items: items.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'OnboardingSlidePageDto', 'total'),
            skip: BuiltValueNullFieldError.checkNotNull(
                skip, r'OnboardingSlidePageDto', 'skip'),
            limit: BuiltValueNullFieldError.checkNotNull(
                limit, r'OnboardingSlidePageDto', 'limit'),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'OnboardingSlidePageDto', 'hasMore'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'OnboardingSlidePageDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
