// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_page_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserPageDto extends UserPageDto {
  @override
  final BuiltList<UserResponseDto> items;
  @override
  final num total;
  @override
  final num skip;
  @override
  final num limit;
  @override
  final bool hasMore;

  factory _$UserPageDto([void Function(UserPageDtoBuilder)? updates]) =>
      (UserPageDtoBuilder()..update(updates))._build();

  _$UserPageDto._(
      {required this.items,
      required this.total,
      required this.skip,
      required this.limit,
      required this.hasMore})
      : super._();
  @override
  UserPageDto rebuild(void Function(UserPageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserPageDtoBuilder toBuilder() => UserPageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserPageDto &&
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
    return (newBuiltValueToStringHelper(r'UserPageDto')
          ..add('items', items)
          ..add('total', total)
          ..add('skip', skip)
          ..add('limit', limit)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class UserPageDtoBuilder implements Builder<UserPageDto, UserPageDtoBuilder> {
  _$UserPageDto? _$v;

  ListBuilder<UserResponseDto>? _items;
  ListBuilder<UserResponseDto> get items =>
      _$this._items ??= ListBuilder<UserResponseDto>();
  set items(ListBuilder<UserResponseDto>? items) => _$this._items = items;

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

  UserPageDtoBuilder() {
    UserPageDto._defaults(this);
  }

  UserPageDtoBuilder get _$this {
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
  void replace(UserPageDto other) {
    _$v = other as _$UserPageDto;
  }

  @override
  void update(void Function(UserPageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserPageDto build() => _build();

  _$UserPageDto _build() {
    _$UserPageDto _$result;
    try {
      _$result = _$v ??
          _$UserPageDto._(
            items: items.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'UserPageDto', 'total'),
            skip: BuiltValueNullFieldError.checkNotNull(
                skip, r'UserPageDto', 'skip'),
            limit: BuiltValueNullFieldError.checkNotNull(
                limit, r'UserPageDto', 'limit'),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'UserPageDto', 'hasMore'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UserPageDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
