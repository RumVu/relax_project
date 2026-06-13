// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companion_asset_page_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CompanionAssetPageDto extends CompanionAssetPageDto {
  @override
  final BuiltList<CompanionAssetResponseDto> items;
  @override
  final num total;
  @override
  final num skip;
  @override
  final num limit;
  @override
  final bool hasMore;

  factory _$CompanionAssetPageDto(
          [void Function(CompanionAssetPageDtoBuilder)? updates]) =>
      (CompanionAssetPageDtoBuilder()..update(updates))._build();

  _$CompanionAssetPageDto._(
      {required this.items,
      required this.total,
      required this.skip,
      required this.limit,
      required this.hasMore})
      : super._();
  @override
  CompanionAssetPageDto rebuild(
          void Function(CompanionAssetPageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CompanionAssetPageDtoBuilder toBuilder() =>
      CompanionAssetPageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompanionAssetPageDto &&
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
    return (newBuiltValueToStringHelper(r'CompanionAssetPageDto')
          ..add('items', items)
          ..add('total', total)
          ..add('skip', skip)
          ..add('limit', limit)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class CompanionAssetPageDtoBuilder
    implements Builder<CompanionAssetPageDto, CompanionAssetPageDtoBuilder> {
  _$CompanionAssetPageDto? _$v;

  ListBuilder<CompanionAssetResponseDto>? _items;
  ListBuilder<CompanionAssetResponseDto> get items =>
      _$this._items ??= ListBuilder<CompanionAssetResponseDto>();
  set items(ListBuilder<CompanionAssetResponseDto>? items) =>
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

  CompanionAssetPageDtoBuilder() {
    CompanionAssetPageDto._defaults(this);
  }

  CompanionAssetPageDtoBuilder get _$this {
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
  void replace(CompanionAssetPageDto other) {
    _$v = other as _$CompanionAssetPageDto;
  }

  @override
  void update(void Function(CompanionAssetPageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CompanionAssetPageDto build() => _build();

  _$CompanionAssetPageDto _build() {
    _$CompanionAssetPageDto _$result;
    try {
      _$result = _$v ??
          _$CompanionAssetPageDto._(
            items: items.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'CompanionAssetPageDto', 'total'),
            skip: BuiltValueNullFieldError.checkNotNull(
                skip, r'CompanionAssetPageDto', 'skip'),
            limit: BuiltValueNullFieldError.checkNotNull(
                limit, r'CompanionAssetPageDto', 'limit'),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'CompanionAssetPageDto', 'hasMore'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CompanionAssetPageDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
