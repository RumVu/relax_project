// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'companion_message_page_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CompanionMessagePageDto extends CompanionMessagePageDto {
  @override
  final BuiltList<CompanionMessageResponseDto> items;
  @override
  final num total;
  @override
  final num skip;
  @override
  final num limit;
  @override
  final bool hasMore;

  factory _$CompanionMessagePageDto(
          [void Function(CompanionMessagePageDtoBuilder)? updates]) =>
      (CompanionMessagePageDtoBuilder()..update(updates))._build();

  _$CompanionMessagePageDto._(
      {required this.items,
      required this.total,
      required this.skip,
      required this.limit,
      required this.hasMore})
      : super._();
  @override
  CompanionMessagePageDto rebuild(
          void Function(CompanionMessagePageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CompanionMessagePageDtoBuilder toBuilder() =>
      CompanionMessagePageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CompanionMessagePageDto &&
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
    return (newBuiltValueToStringHelper(r'CompanionMessagePageDto')
          ..add('items', items)
          ..add('total', total)
          ..add('skip', skip)
          ..add('limit', limit)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class CompanionMessagePageDtoBuilder
    implements
        Builder<CompanionMessagePageDto, CompanionMessagePageDtoBuilder> {
  _$CompanionMessagePageDto? _$v;

  ListBuilder<CompanionMessageResponseDto>? _items;
  ListBuilder<CompanionMessageResponseDto> get items =>
      _$this._items ??= ListBuilder<CompanionMessageResponseDto>();
  set items(ListBuilder<CompanionMessageResponseDto>? items) =>
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

  CompanionMessagePageDtoBuilder() {
    CompanionMessagePageDto._defaults(this);
  }

  CompanionMessagePageDtoBuilder get _$this {
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
  void replace(CompanionMessagePageDto other) {
    _$v = other as _$CompanionMessagePageDto;
  }

  @override
  void update(void Function(CompanionMessagePageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CompanionMessagePageDto build() => _build();

  _$CompanionMessagePageDto _build() {
    _$CompanionMessagePageDto _$result;
    try {
      _$result = _$v ??
          _$CompanionMessagePageDto._(
            items: items.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'CompanionMessagePageDto', 'total'),
            skip: BuiltValueNullFieldError.checkNotNull(
                skip, r'CompanionMessagePageDto', 'skip'),
            limit: BuiltValueNullFieldError.checkNotNull(
                limit, r'CompanionMessagePageDto', 'limit'),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'CompanionMessagePageDto', 'hasMore'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CompanionMessagePageDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
