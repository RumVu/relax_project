// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_checkin_page_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$MoodCheckinPageDto extends MoodCheckinPageDto {
  @override
  final BuiltList<MoodCheckinResponseDto> items;
  @override
  final num total;
  @override
  final num skip;
  @override
  final num limit;
  @override
  final bool hasMore;

  factory _$MoodCheckinPageDto(
          [void Function(MoodCheckinPageDtoBuilder)? updates]) =>
      (MoodCheckinPageDtoBuilder()..update(updates))._build();

  _$MoodCheckinPageDto._(
      {required this.items,
      required this.total,
      required this.skip,
      required this.limit,
      required this.hasMore})
      : super._();
  @override
  MoodCheckinPageDto rebuild(
          void Function(MoodCheckinPageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  MoodCheckinPageDtoBuilder toBuilder() =>
      MoodCheckinPageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is MoodCheckinPageDto &&
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
    return (newBuiltValueToStringHelper(r'MoodCheckinPageDto')
          ..add('items', items)
          ..add('total', total)
          ..add('skip', skip)
          ..add('limit', limit)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class MoodCheckinPageDtoBuilder
    implements Builder<MoodCheckinPageDto, MoodCheckinPageDtoBuilder> {
  _$MoodCheckinPageDto? _$v;

  ListBuilder<MoodCheckinResponseDto>? _items;
  ListBuilder<MoodCheckinResponseDto> get items =>
      _$this._items ??= ListBuilder<MoodCheckinResponseDto>();
  set items(ListBuilder<MoodCheckinResponseDto>? items) =>
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

  MoodCheckinPageDtoBuilder() {
    MoodCheckinPageDto._defaults(this);
  }

  MoodCheckinPageDtoBuilder get _$this {
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
  void replace(MoodCheckinPageDto other) {
    _$v = other as _$MoodCheckinPageDto;
  }

  @override
  void update(void Function(MoodCheckinPageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  MoodCheckinPageDto build() => _build();

  _$MoodCheckinPageDto _build() {
    _$MoodCheckinPageDto _$result;
    try {
      _$result = _$v ??
          _$MoodCheckinPageDto._(
            items: items.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'MoodCheckinPageDto', 'total'),
            skip: BuiltValueNullFieldError.checkNotNull(
                skip, r'MoodCheckinPageDto', 'skip'),
            limit: BuiltValueNullFieldError.checkNotNull(
                limit, r'MoodCheckinPageDto', 'limit'),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'MoodCheckinPageDto', 'hasMore'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'MoodCheckinPageDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
