// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_plan_limit_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BillingPlanLimitDto extends BillingPlanLimitDto {
  @override
  final String name;
  @override
  final num value;
  @override
  final String? unit;

  factory _$BillingPlanLimitDto(
          [void Function(BillingPlanLimitDtoBuilder)? updates]) =>
      (BillingPlanLimitDtoBuilder()..update(updates))._build();

  _$BillingPlanLimitDto._({required this.name, required this.value, this.unit})
      : super._();
  @override
  BillingPlanLimitDto rebuild(
          void Function(BillingPlanLimitDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BillingPlanLimitDtoBuilder toBuilder() =>
      BillingPlanLimitDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BillingPlanLimitDto &&
        name == other.name &&
        value == other.value &&
        unit == other.unit;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, value.hashCode);
    _$hash = $jc(_$hash, unit.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BillingPlanLimitDto')
          ..add('name', name)
          ..add('value', value)
          ..add('unit', unit))
        .toString();
  }
}

class BillingPlanLimitDtoBuilder
    implements Builder<BillingPlanLimitDto, BillingPlanLimitDtoBuilder> {
  _$BillingPlanLimitDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  num? _value;
  num? get value => _$this._value;
  set value(num? value) => _$this._value = value;

  String? _unit;
  String? get unit => _$this._unit;
  set unit(String? unit) => _$this._unit = unit;

  BillingPlanLimitDtoBuilder() {
    BillingPlanLimitDto._defaults(this);
  }

  BillingPlanLimitDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _value = $v.value;
      _unit = $v.unit;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BillingPlanLimitDto other) {
    _$v = other as _$BillingPlanLimitDto;
  }

  @override
  void update(void Function(BillingPlanLimitDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BillingPlanLimitDto build() => _build();

  _$BillingPlanLimitDto _build() {
    final _$result = _$v ??
        _$BillingPlanLimitDto._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'BillingPlanLimitDto', 'name'),
          value: BuiltValueNullFieldError.checkNotNull(
              value, r'BillingPlanLimitDto', 'value'),
          unit: unit,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
