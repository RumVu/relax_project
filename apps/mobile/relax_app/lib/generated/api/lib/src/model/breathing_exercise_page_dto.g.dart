// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'breathing_exercise_page_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BreathingExercisePageDto extends BreathingExercisePageDto {
  @override
  final BuiltList<BreathingExerciseResponseDto> items;
  @override
  final num total;
  @override
  final num skip;
  @override
  final num limit;
  @override
  final bool hasMore;

  factory _$BreathingExercisePageDto(
          [void Function(BreathingExercisePageDtoBuilder)? updates]) =>
      (BreathingExercisePageDtoBuilder()..update(updates))._build();

  _$BreathingExercisePageDto._(
      {required this.items,
      required this.total,
      required this.skip,
      required this.limit,
      required this.hasMore})
      : super._();
  @override
  BreathingExercisePageDto rebuild(
          void Function(BreathingExercisePageDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BreathingExercisePageDtoBuilder toBuilder() =>
      BreathingExercisePageDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BreathingExercisePageDto &&
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
    return (newBuiltValueToStringHelper(r'BreathingExercisePageDto')
          ..add('items', items)
          ..add('total', total)
          ..add('skip', skip)
          ..add('limit', limit)
          ..add('hasMore', hasMore))
        .toString();
  }
}

class BreathingExercisePageDtoBuilder
    implements
        Builder<BreathingExercisePageDto, BreathingExercisePageDtoBuilder> {
  _$BreathingExercisePageDto? _$v;

  ListBuilder<BreathingExerciseResponseDto>? _items;
  ListBuilder<BreathingExerciseResponseDto> get items =>
      _$this._items ??= ListBuilder<BreathingExerciseResponseDto>();
  set items(ListBuilder<BreathingExerciseResponseDto>? items) =>
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

  BreathingExercisePageDtoBuilder() {
    BreathingExercisePageDto._defaults(this);
  }

  BreathingExercisePageDtoBuilder get _$this {
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
  void replace(BreathingExercisePageDto other) {
    _$v = other as _$BreathingExercisePageDto;
  }

  @override
  void update(void Function(BreathingExercisePageDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BreathingExercisePageDto build() => _build();

  _$BreathingExercisePageDto _build() {
    _$BreathingExercisePageDto _$result;
    try {
      _$result = _$v ??
          _$BreathingExercisePageDto._(
            items: items.build(),
            total: BuiltValueNullFieldError.checkNotNull(
                total, r'BreathingExercisePageDto', 'total'),
            skip: BuiltValueNullFieldError.checkNotNull(
                skip, r'BreathingExercisePageDto', 'skip'),
            limit: BuiltValueNullFieldError.checkNotNull(
                limit, r'BreathingExercisePageDto', 'limit'),
            hasMore: BuiltValueNullFieldError.checkNotNull(
                hasMore, r'BreathingExercisePageDto', 'hasMore'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BreathingExercisePageDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
