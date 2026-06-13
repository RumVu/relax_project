// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ambient_sound_page_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AmbientSoundPageDto extends AmbientSoundPageDto {
  @override
  final BuiltList<AmbientSoundResponseDto> items;
  @override
  final num total;
  @override
  final num skip;
  @override
  final num limit;
  @override
  final bool hasMore;

  factory _$AmbientSoundPageDto(
          [void Function(AmbientSoundPageDtoBuilder)? updates]) =>
      (AmbientSoundPageDtoBuilder()..update(updates))._build();

  _$AmbientSoundPageDto._(
      {required this.items,
      required this.total,
      required this.skip,
      required this.limit,
      required this.hasMore})
      : super._();
  @override
  AmbientSoundPageDto rebuild(
          void Function(AmbientSoundPageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AmbientSoundPageDtoBuilder toBuilder() =>
      AmbientSoundPageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AmbientSoundPageDto &&
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
    return (newBuiltValueToStringHelper(r'AmbientSoundPageDto')
          ..add('items', items)
          ..add('total', total)
          ..add('skip', skip)
          ..add('limit', limit)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class AmbientSoundPageDtoBuilder
    implements Builder<AmbientSoundPageDto, AmbientSoundPageDtoBuilder> {
  _$AmbientSoundPageDto? _$v;

  ListBuilder<AmbientSoundResponseDto>? _items;
  ListBuilder<AmbientSoundResponseDto> get items =>
      _$this._items ??= ListBuilder<AmbientSoundResponseDto>();
  set items(ListBuilder<AmbientSoundResponseDto>? items) =>
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

  AmbientSoundPageDtoBuilder() {
    AmbientSoundPageDto._defaults(this);
  }

  AmbientSoundPageDtoBuilder get _$this {
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
  void replace(AmbientSoundPageDto other) {
    _$v = other as _$AmbientSoundPageDto;
  }

  @override
  void update(void Function(AmbientSoundPageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AmbientSoundPageDto build() => _build();

  _$AmbientSoundPageDto _build() {
    _$AmbientSoundPageDto _$result;
    try {
      _$result = _$v ??
          _$AmbientSoundPageDto._(
            items: items.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'AmbientSoundPageDto', 'total'),
            skip: BuiltValueNullFieldError.checkNotNull(
                skip, r'AmbientSoundPageDto', 'skip'),
            limit: BuiltValueNullFieldError.checkNotNull(
                limit, r'AmbientSoundPageDto', 'limit'),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'AmbientSoundPageDto', 'hasMore'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'AmbientSoundPageDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
