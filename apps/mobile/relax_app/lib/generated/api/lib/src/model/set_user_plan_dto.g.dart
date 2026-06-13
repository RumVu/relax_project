// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'set_user_plan_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SetUserPlanDto extends SetUserPlanDto {
  @override
  final String planName;

  factory _$SetUserPlanDto([void Function(SetUserPlanDtoBuilder)? updates]) =>
      (SetUserPlanDtoBuilder()..update(updates))._build();

  _$SetUserPlanDto._({required this.planName}) : super._();
  @override
  SetUserPlanDto rebuild(void Function(SetUserPlanDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SetUserPlanDtoBuilder toBuilder() => SetUserPlanDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SetUserPlanDto && planName == other.planName;
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
    return (newBuiltValueToStringHelper(r'SetUserPlanDto')
          ..add('planName', planName))
        .toString();
  }
}

class SetUserPlanDtoBuilder
    implements Builder<SetUserPlanDto, SetUserPlanDtoBuilder> {
  _$SetUserPlanDto? _$v;

  String? _planName;
  String? get planName => _$this._planName;
  set planName(String? planName) => _$this._planName = planName;

  SetUserPlanDtoBuilder() {
    SetUserPlanDto._defaults(this);
  }

  SetUserPlanDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _planName = $v.planName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SetUserPlanDto other) {
    _$v = other as _$SetUserPlanDto;
  }

  @override
  void update(void Function(SetUserPlanDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SetUserPlanDto build() => _build();

  _$SetUserPlanDto _build() {
    final _$result = _$v ??
        _$SetUserPlanDto._(
          planName: BuiltValueNullFieldError.checkNotNull(
              planName, r'SetUserPlanDto', 'planName'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
