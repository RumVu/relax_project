// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_page_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ReminderPageDto extends ReminderPageDto {
  @override
  final BuiltList<ReminderResponseDto> items;
  @override
  final num total;
  @override
  final num skip;
  @override
  final num limit;
  @override
  final bool hasMore;

  factory _$ReminderPageDto([void Function(ReminderPageDtoBuilder)? updates]) =>
      (ReminderPageDtoBuilder()..update(updates))._build();

  _$ReminderPageDto._(
      {required this.items,
      required this.total,
      required this.skip,
      required this.limit,
      required this.hasMore})
      : super._();
  @override
  ReminderPageDto rebuild(void Function(ReminderPageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ReminderPageDtoBuilder toBuilder() => ReminderPageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ReminderPageDto &&
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
    return (newBuiltValueToStringHelper(r'ReminderPageDto')
          ..add('items', items)
          ..add('total', total)
          ..add('skip', skip)
          ..add('limit', limit)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class ReminderPageDtoBuilder
    implements Builder<ReminderPageDto, ReminderPageDtoBuilder> {
  _$ReminderPageDto? _$v;

  ListBuilder<ReminderResponseDto>? _items;
  ListBuilder<ReminderResponseDto> get items =>
      _$this._items ??= ListBuilder<ReminderResponseDto>();
  set items(ListBuilder<ReminderResponseDto>? items) => _$this._items = items;

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

  ReminderPageDtoBuilder() {
    ReminderPageDto._defaults(this);
  }

  ReminderPageDtoBuilder get _$this {
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
  void replace(ReminderPageDto other) {
    _$v = other as _$ReminderPageDto;
  }

  @override
  void update(void Function(ReminderPageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ReminderPageDto build() => _build();

  _$ReminderPageDto _build() {
    _$ReminderPageDto _$result;
    try {
      _$result = _$v ??
          _$ReminderPageDto._(
            items: items.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'ReminderPageDto', 'total'),
            skip: BuiltValueNullFieldError.checkNotNull(
                skip, r'ReminderPageDto', 'skip'),
            limit: BuiltValueNullFieldError.checkNotNull(
                limit, r'ReminderPageDto', 'limit'),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'ReminderPageDto', 'hasMore'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ReminderPageDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
