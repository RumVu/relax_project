// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unread_count_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UnreadCountResponseDto extends UnreadCountResponseDto {
  @override
  final num count;

  factory _$UnreadCountResponseDto(
          [void Function(UnreadCountResponseDtoBuilder)? updates]) =>
      (UnreadCountResponseDtoBuilder()..update(updates))._build();

  _$UnreadCountResponseDto._({required this.count}) : super._();
  @override
  UnreadCountResponseDto rebuild(
          void Function(UnreadCountResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UnreadCountResponseDtoBuilder toBuilder() =>
      UnreadCountResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UnreadCountResponseDto && count == other.count;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, count.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UnreadCountResponseDto')
          ..add('count', count))
        .toString();
  }
}

class UnreadCountResponseDtoBuilder
    implements Builder<UnreadCountResponseDto, UnreadCountResponseDtoBuilder> {
  _$UnreadCountResponseDto? _$v;

  num? _count;
  num? get count => _$this._count;
  set count(num? count) => _$this._count = count;

  UnreadCountResponseDtoBuilder() {
    UnreadCountResponseDto._defaults(this);
  }

  UnreadCountResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _count = $v.count;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UnreadCountResponseDto other) {
    _$v = other as _$UnreadCountResponseDto;
  }

  @override
  void update(void Function(UnreadCountResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UnreadCountResponseDto build() => _build();

  _$UnreadCountResponseDto _build() {
    final _$result = _$v ??
        _$UnreadCountResponseDto._(
          count: BuiltValueNullFieldError.checkNotNull(
              count, r'UnreadCountResponseDto', 'count'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
