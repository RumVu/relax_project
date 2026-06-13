// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feedback_insight_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$FeedbackInsightDto extends FeedbackInsightDto {
  @override
  final bool useful;

  factory _$FeedbackInsightDto(
          [void Function(FeedbackInsightDtoBuilder)? updates]) =>
      (FeedbackInsightDtoBuilder()..update(updates))._build();

  _$FeedbackInsightDto._({required this.useful}) : super._();
  @override
  FeedbackInsightDto rebuild(
          void Function(FeedbackInsightDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  FeedbackInsightDtoBuilder toBuilder() =>
      FeedbackInsightDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is FeedbackInsightDto && useful == other.useful;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, useful.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'FeedbackInsightDto')
          ..add('useful', useful))
        .toString();
  }
}

class FeedbackInsightDtoBuilder
    implements Builder<FeedbackInsightDto, FeedbackInsightDtoBuilder> {
  _$FeedbackInsightDto? _$v;

  bool? _useful;
  bool? get useful => _$this._useful;
  set useful(bool? useful) => _$this._useful = useful;

  FeedbackInsightDtoBuilder() {
    FeedbackInsightDto._defaults(this);
  }

  FeedbackInsightDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _useful = $v.useful;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(FeedbackInsightDto other) {
    _$v = other as _$FeedbackInsightDto;
  }

  @override
  void update(void Function(FeedbackInsightDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  FeedbackInsightDto build() => _build();

  _$FeedbackInsightDto _build() {
    final _$result = _$v ??
        _$FeedbackInsightDto._(
          useful: BuiltValueNullFieldError.checkNotNull(
              useful, r'FeedbackInsightDto', 'useful'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
