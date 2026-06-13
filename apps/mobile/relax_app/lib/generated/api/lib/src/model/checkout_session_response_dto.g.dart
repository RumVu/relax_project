// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_session_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CheckoutSessionResponseDto extends CheckoutSessionResponseDto {
  @override
  final bool configured;
  @override
  final String provider;
  @override
  final JsonObject tier;
  @override
  final CheckoutResolvedPlanDto plan;
  @override
  final JsonObject payment;
  @override
  final CheckoutSessionStatusDto checkout;

  factory _$CheckoutSessionResponseDto(
          [void Function(CheckoutSessionResponseDtoBuilder)? updates]) =>
      (CheckoutSessionResponseDtoBuilder()..update(updates))._build();

  _$CheckoutSessionResponseDto._(
      {required this.configured,
      required this.provider,
      required this.tier,
      required this.plan,
      required this.payment,
      required this.checkout})
      : super._();
  @override
  CheckoutSessionResponseDto rebuild(
          void Function(CheckoutSessionResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CheckoutSessionResponseDtoBuilder toBuilder() =>
      CheckoutSessionResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CheckoutSessionResponseDto &&
        configured == other.configured &&
        provider == other.provider &&
        tier == other.tier &&
        plan == other.plan &&
        payment == other.payment &&
        checkout == other.checkout;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, configured.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, tier.hashCode);
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jc(_$hash, payment.hashCode);
    _$hash = $jc(_$hash, checkout.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CheckoutSessionResponseDto')
          ..add('configured', configured)
          ..add('provider', provider)
          ..add('tier', tier)
          ..add('plan', plan)
          ..add('payment', payment)
          ..add('checkout', checkout))
        .toString();
  }
}

class CheckoutSessionResponseDtoBuilder
    implements
        Builder<CheckoutSessionResponseDto, CheckoutSessionResponseDtoBuilder> {
  _$CheckoutSessionResponseDto? _$v;

  bool? _configured;
  bool? get configured => _$this._configured;
  set configured(bool? configured) => _$this._configured = configured;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  JsonObject? _tier;
  JsonObject? get tier => _$this._tier;
  set tier(JsonObject? tier) => _$this._tier = tier;

  CheckoutResolvedPlanDtoBuilder? _plan;
  CheckoutResolvedPlanDtoBuilder get plan =>
      _$this._plan ??= CheckoutResolvedPlanDtoBuilder();
  set plan(CheckoutResolvedPlanDtoBuilder? plan) => _$this._plan = plan;

  JsonObject? _payment;
  JsonObject? get payment => _$this._payment;
  set payment(JsonObject? payment) => _$this._payment = payment;

  CheckoutSessionStatusDtoBuilder? _checkout;
  CheckoutSessionStatusDtoBuilder get checkout =>
      _$this._checkout ??= CheckoutSessionStatusDtoBuilder();
  set checkout(CheckoutSessionStatusDtoBuilder? checkout) =>
      _$this._checkout = checkout;

  CheckoutSessionResponseDtoBuilder() {
    CheckoutSessionResponseDto._defaults(this);
  }

  CheckoutSessionResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _configured = $v.configured;
      _provider = $v.provider;
      _tier = $v.tier;
      _plan = $v.plan.toBuilder();
      _payment = $v.payment;
      _checkout = $v.checkout.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CheckoutSessionResponseDto other) {
    _$v = other as _$CheckoutSessionResponseDto;
  }

  @override
  void update(void Function(CheckoutSessionResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CheckoutSessionResponseDto build() => _build();

  _$CheckoutSessionResponseDto _build() {
    _$CheckoutSessionResponseDto _$result;
    try {
      _$result = _$v ??
          _$CheckoutSessionResponseDto._(
            configured: BuiltValueNullFieldError.checkNotNull(
                configured, r'CheckoutSessionResponseDto', 'configured'),
            provider: BuiltValueNullFieldError.checkNotNull(
                provider, r'CheckoutSessionResponseDto', 'provider'),
            tier: BuiltValueNullFieldError.checkNotNull(
                tier, r'CheckoutSessionResponseDto', 'tier'),
            plan: plan.build(),
            payment: BuiltValueNullFieldError.checkNotNull(
                payment, r'CheckoutSessionResponseDto', 'payment'),
            checkout: checkout.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'plan';
        plan.build();

        _$failedField = 'checkout';
        checkout.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CheckoutSessionResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
