// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_payment_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConfirmPaymentDto extends ConfirmPaymentDto {
  @override
  final String planName;

  factory _$ConfirmPaymentDto(
          [void Function(ConfirmPaymentDtoBuilder)? updates]) =>
      (ConfirmPaymentDtoBuilder()..update(updates))._build();

  _$ConfirmPaymentDto._({required this.planName}) : super._();
  @override
  ConfirmPaymentDto rebuild(void Function(ConfirmPaymentDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConfirmPaymentDtoBuilder toBuilder() =>
      ConfirmPaymentDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConfirmPaymentDto && planName == other.planName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, planName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConfirmPaymentDto')
          ..add('planName', planName))
        .toString();
  }
}

class ConfirmPaymentDtoBuilder
    implements Builder<ConfirmPaymentDto, ConfirmPaymentDtoBuilder> {
  _$ConfirmPaymentDto? _$v;

  String? _planName;
  String? get planName => _$this._planName;
  set planName(String? planName) => _$this._planName = planName;

  ConfirmPaymentDtoBuilder() {
    ConfirmPaymentDto._defaults(this);
  }

  ConfirmPaymentDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _planName = $v.planName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConfirmPaymentDto other) {
    _$v = other as _$ConfirmPaymentDto;
  }

  @override
  void update(void Function(ConfirmPaymentDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConfirmPaymentDto build() => _build();

  _$ConfirmPaymentDto _build() {
    final _$result = _$v ??
        _$ConfirmPaymentDto._(
          planName: BuiltValueNullFieldError.checkNotNull(
              planName, r'ConfirmPaymentDto', 'planName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
