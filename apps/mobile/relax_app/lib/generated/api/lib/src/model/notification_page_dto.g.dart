// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_page_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$NotificationPageDto extends NotificationPageDto {
  @override
  final BuiltList<NotificationResponseDto> items;
  @override
  final num total;
  @override
  final num skip;
  @override
  final num limit;
  @override
  final bool hasMore;

  factory _$NotificationPageDto(
          [void Function(NotificationPageDtoBuilder)? updates]) =>
      (NotificationPageDtoBuilder()..update(updates))._build();

  _$NotificationPageDto._(
      {required this.items,
      required this.total,
      required this.skip,
      required this.limit,
      required this.hasMore})
      : super._();
  @override
  NotificationPageDto rebuild(
          void Function(NotificationPageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  NotificationPageDtoBuilder toBuilder() =>
      NotificationPageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is NotificationPageDto &&
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
    return (newBuiltValueToStringHelper(r'NotificationPageDto')
          ..add('items', items)
          ..add('total', total)
          ..add('skip', skip)
          ..add('limit', limit)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class NotificationPageDtoBuilder
    implements Builder<NotificationPageDto, NotificationPageDtoBuilder> {
  _$NotificationPageDto? _$v;

  ListBuilder<NotificationResponseDto>? _items;
  ListBuilder<NotificationResponseDto> get items =>
      _$this._items ??= ListBuilder<NotificationResponseDto>();
  set items(ListBuilder<NotificationResponseDto>? items) =>
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

  NotificationPageDtoBuilder() {
    NotificationPageDto._defaults(this);
  }

  NotificationPageDtoBuilder get _$this {
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
  void replace(NotificationPageDto other) {
    _$v = other as _$NotificationPageDto;
  }

  @override
  void update(void Function(NotificationPageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  NotificationPageDto build() => _build();

  _$NotificationPageDto _build() {
    _$NotificationPageDto _$result;
    try {
      _$result = _$v ??
          _$NotificationPageDto._(
            items: items.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'NotificationPageDto', 'total'),
            skip: BuiltValueNullFieldError.checkNotNull(
                skip, r'NotificationPageDto', 'skip'),
            limit: BuiltValueNullFieldError.checkNotNull(
                limit, r'NotificationPageDto', 'limit'),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'NotificationPageDto', 'hasMore'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'NotificationPageDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
