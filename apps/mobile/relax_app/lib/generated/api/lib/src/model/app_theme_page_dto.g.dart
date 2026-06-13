// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_theme_page_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppThemePageDto extends AppThemePageDto {
  @override
  final BuiltList<AppThemeResponseDto> items;
  @override
  final num total;
  @override
  final num skip;
  @override
  final num limit;
  @override
  final bool hasMore;

  factory _$AppThemePageDto([void Function(AppThemePageDtoBuilder)? updates]) =>
      (AppThemePageDtoBuilder()..update(updates))._build();

  _$AppThemePageDto._(
      {required this.items,
      required this.total,
      required this.skip,
      required this.limit,
      required this.hasMore})
      : super._();
  @override
  AppThemePageDto rebuild(void Function(AppThemePageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AppThemePageDtoBuilder toBuilder() => AppThemePageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppThemePageDto &&
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
    return (newBuiltValueToStringHelper(r'AppThemePageDto')
          ..add('items', items)
          ..add('total', total)
          ..add('skip', skip)
          ..add('limit', limit)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class AppThemePageDtoBuilder
    implements Builder<AppThemePageDto, AppThemePageDtoBuilder> {
  _$AppThemePageDto? _$v;

  ListBuilder<AppThemeResponseDto>? _items;
  ListBuilder<AppThemeResponseDto> get items =>
      _$this._items ??= ListBuilder<AppThemeResponseDto>();
  set items(ListBuilder<AppThemeResponseDto>? items) => _$this._items = items;

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

  AppThemePageDtoBuilder() {
    AppThemePageDto._defaults(this);
  }

  AppThemePageDtoBuilder get _$this {
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
  void replace(AppThemePageDto other) {
    _$v = other as _$AppThemePageDto;
  }

  @override
  void update(void Function(AppThemePageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AppThemePageDto build() => _build();

  _$AppThemePageDto _build() {
    _$AppThemePageDto _$result;
    try {
      _$result = _$v ??
          _$AppThemePageDto._(
            items: items.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'AppThemePageDto', 'total'),
            skip: BuiltValueNullFieldError.checkNotNull(
                skip, r'AppThemePageDto', 'skip'),
            limit: BuiltValueNullFieldError.checkNotNull(
                limit, r'AppThemePageDto', 'limit'),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'AppThemePageDto', 'hasMore'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AppThemePageDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
