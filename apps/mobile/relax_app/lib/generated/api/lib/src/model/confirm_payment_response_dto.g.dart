// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_payment_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConfirmPaymentResponseDto extends ConfirmPaymentResponseDto {
  @override
  final PaymentResponseDto payment;
  @override
  final SubscriptionResponseDto subscription;
  @override
  final ConfirmPaymentPlanDto plan;

  factory _$ConfirmPaymentResponseDto(
          [void Function(ConfirmPaymentResponseDtoBuilder)? updates]) =>
      (ConfirmPaymentResponseDtoBuilder()..update(updates))._build();

  _$ConfirmPaymentResponseDto._(
      {required this.payment, required this.subscription, required this.plan})
      : super._();
  @override
  ConfirmPaymentResponseDto rebuild(
          void Function(ConfirmPaymentResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConfirmPaymentResponseDtoBuilder toBuilder() =>
      ConfirmPaymentResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConfirmPaymentResponseDto &&
        payment == other.payment &&
        subscription == other.subscription &&
        plan == other.plan;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, payment.hashCode);
    _$hash = $jc(_$hash, subscription.hashCode);
    _$hash = $jc(_$hash, plan.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConfirmPaymentResponseDto')
          ..add('payment', payment)
          ..add('subscription', subscription)
          ..add('plan', plan))
        .toString();
  }
}

class ConfirmPaymentResponseDtoBuilder
    implements
        Builder<ConfirmPaymentResponseDto, ConfirmPaymentResponseDtoBuilder> {
  _$ConfirmPaymentResponseDto? _$v;

  PaymentResponseDtoBuilder? _payment;
  PaymentResponseDtoBuilder get payment =>
      _$this._payment ??= PaymentResponseDtoBuilder();
  set payment(PaymentResponseDtoBuilder? payment) => _$this._payment = payment;

  SubscriptionResponseDtoBuilder? _subscription;
  SubscriptionResponseDtoBuilder get subscription =>
      _$this._subscription ??= SubscriptionResponseDtoBuilder();
  set subscription(SubscriptionResponseDtoBuilder? subscription) =>
      _$this._subscription = subscription;

  ConfirmPaymentPlanDtoBuilder? _plan;
  ConfirmPaymentPlanDtoBuilder get plan =>
      _$this._plan ??= ConfirmPaymentPlanDtoBuilder();
  set plan(ConfirmPaymentPlanDtoBuilder? plan) => _$this._plan = plan;

  ConfirmPaymentResponseDtoBuilder() {
    ConfirmPaymentResponseDto._defaults(this);
  }

  ConfirmPaymentResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _payment = $v.payment.toBuilder();
      _subscription = $v.subscription.toBuilder();
      _plan = $v.plan.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConfirmPaymentResponseDto other) {
    _$v = other as _$ConfirmPaymentResponseDto;
  }

  @override
  void update(void Function(ConfirmPaymentResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConfirmPaymentResponseDto build() => _build();

  _$ConfirmPaymentResponseDto _build() {
    _$ConfirmPaymentResponseDto _$result;
    try {
      _$result = _$v ??
          _$ConfirmPaymentResponseDto._(
            payment: payment.build(),
            subscription: subscription.build(),
            plan: plan.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'payment';
        payment.build();
        _$failedField = 'subscription';
        subscription.build();
        _$failedField = 'plan';
        plan.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'ConfirmPaymentResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
