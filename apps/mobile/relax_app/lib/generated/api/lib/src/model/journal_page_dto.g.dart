// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_page_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$JournalPageDto extends JournalPageDto {
  @override
  final BuiltList<JournalResponseDto> items;
  @override
  final num total;
  @override
  final num skip;
  @override
  final num limit;
  @override
  final bool hasMore;

  factory _$JournalPageDto([void Function(JournalPageDtoBuilder)? updates]) =>
      (JournalPageDtoBuilder()..update(updates))._build();

  _$JournalPageDto._(
      {required this.items,
      required this.total,
      required this.skip,
      required this.limit,
      required this.hasMore})
      : super._();
  @override
  JournalPageDto rebuild(void Function(JournalPageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  JournalPageDtoBuilder toBuilder() => JournalPageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is JournalPageDto &&
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
    return (newBuiltValueToStringHelper(r'JournalPageDto')
          ..add('items', items)
          ..add('total', total)
          ..add('skip', skip)
          ..add('limit', limit)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class JournalPageDtoBuilder
    implements Builder<JournalPageDto, JournalPageDtoBuilder> {
  _$JournalPageDto? _$v;

  ListBuilder<JournalResponseDto>? _items;
  ListBuilder<JournalResponseDto> get items =>
      _$this._items ??= ListBuilder<JournalResponseDto>();
  set items(ListBuilder<JournalResponseDto>? items) => _$this._items = items;

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

  JournalPageDtoBuilder() {
    JournalPageDto._defaults(this);
  }

  JournalPageDtoBuilder get _$this {
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
  void replace(JournalPageDto other) {
    _$v = other as _$JournalPageDto;
  }

  @override
  void update(void Function(JournalPageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  JournalPageDto build() => _build();

  _$JournalPageDto _build() {
    _$JournalPageDto _$result;
    try {
      _$result = _$v ??
          _$JournalPageDto._(
            items: items.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'JournalPageDto', 'total'),
            skip: BuiltValueNullFieldError.checkNotNull(
                skip, r'JournalPageDto', 'skip'),
            limit: BuiltValueNullFieldError.checkNotNull(
                limit, r'JournalPageDto', 'limit'),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'JournalPageDto', 'hasMore'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'JournalPageDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
