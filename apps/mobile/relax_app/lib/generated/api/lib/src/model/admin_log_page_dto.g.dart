// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_log_page_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AdminLogPageDto extends AdminLogPageDto {
  @override
  final BuiltList<AdminLogResponseDto> items;
  @override
  final num total;
  @override
  final num skip;
  @override
  final num limit;
  @override
  final bool hasMore;

  factory _$AdminLogPageDto([void Function(AdminLogPageDtoBuilder)? updates]) =>
      (AdminLogPageDtoBuilder()..update(updates))._build();

  _$AdminLogPageDto._(
      {required this.items,
      required this.total,
      required this.skip,
      required this.limit,
      required this.hasMore})
      : super._();
  @override
  AdminLogPageDto rebuild(void Function(AdminLogPageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AdminLogPageDtoBuilder toBuilder() => AdminLogPageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AdminLogPageDto &&
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
    return (newBuiltValueToStringHelper(r'AdminLogPageDto')
          ..add('items', items)
          ..add('total', total)
          ..add('skip', skip)
          ..add('limit', limit)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class AdminLogPageDtoBuilder
    implements Builder<AdminLogPageDto, AdminLogPageDtoBuilder> {
  _$AdminLogPageDto? _$v;

  ListBuilder<AdminLogResponseDto>? _items;
  ListBuilder<AdminLogResponseDto> get items =>
      _$this._items ??= ListBuilder<AdminLogResponseDto>();
  set items(ListBuilder<AdminLogResponseDto>? items) => _$this._items = items;

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

  AdminLogPageDtoBuilder() {
    AdminLogPageDto._defaults(this);
  }

  AdminLogPageDtoBuilder get _$this {
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
  void replace(AdminLogPageDto other) {
    _$v = other as _$AdminLogPageDto;
  }

  @override
  void update(void Function(AdminLogPageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AdminLogPageDto build() => _build();

  _$AdminLogPageDto _build() {
    _$AdminLogPageDto _$result;
    try {
      _$result = _$v ??
          _$AdminLogPageDto._(
            items: items.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'AdminLogPageDto', 'total'),
            skip: BuiltValueNullFieldError.checkNotNull(
                skip, r'AdminLogPageDto', 'skip'),
            limit: BuiltValueNullFieldError.checkNotNull(
                limit, r'AdminLogPageDto', 'limit'),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'AdminLogPageDto', 'hasMore'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AdminLogPageDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
