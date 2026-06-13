// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relax_session_page_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RelaxSessionPageDto extends RelaxSessionPageDto {
  @override
  final BuiltList<RelaxSessionResponseDto> items;
  @override
  final num total;
  @override
  final num skip;
  @override
  final num limit;
  @override
  final bool hasMore;

  factory _$RelaxSessionPageDto(
          [void Function(RelaxSessionPageDtoBuilder)? updates]) =>
      (RelaxSessionPageDtoBuilder()..update(updates))._build();

  _$RelaxSessionPageDto._(
      {required this.items,
      required this.total,
      required this.skip,
      required this.limit,
      required this.hasMore})
      : super._();
  @override
  RelaxSessionPageDto rebuild(
          void Function(RelaxSessionPageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RelaxSessionPageDtoBuilder toBuilder() =>
      RelaxSessionPageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RelaxSessionPageDto &&
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
    return (newBuiltValueToStringHelper(r'RelaxSessionPageDto')
          ..add('items', items)
          ..add('total', total)
          ..add('skip', skip)
          ..add('limit', limit)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class RelaxSessionPageDtoBuilder
    implements Builder<RelaxSessionPageDto, RelaxSessionPageDtoBuilder> {
  _$RelaxSessionPageDto? _$v;

  ListBuilder<RelaxSessionResponseDto>? _items;
  ListBuilder<RelaxSessionResponseDto> get items =>
      _$this._items ??= ListBuilder<RelaxSessionResponseDto>();
  set items(ListBuilder<RelaxSessionResponseDto>? items) =>
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

  RelaxSessionPageDtoBuilder() {
    RelaxSessionPageDto._defaults(this);
  }

  RelaxSessionPageDtoBuilder get _$this {
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
  void replace(RelaxSessionPageDto other) {
    _$v = other as _$RelaxSessionPageDto;
  }

  @override
  void update(void Function(RelaxSessionPageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RelaxSessionPageDto build() => _build();

  _$RelaxSessionPageDto _build() {
    _$RelaxSessionPageDto _$result;
    try {
      _$result = _$v ??
          _$RelaxSessionPageDto._(
            items: items.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'RelaxSessionPageDto', 'total'),
            skip: BuiltValueNullFieldError.checkNotNull(
                skip, r'RelaxSessionPageDto', 'skip'),
            limit: BuiltValueNullFieldError.checkNotNull(
                limit, r'RelaxSessionPageDto', 'limit'),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'RelaxSessionPageDto', 'hasMore'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RelaxSessionPageDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
