// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_me_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BillingMeResponseDto extends BillingMeResponseDto {
  @override
  final JsonObject subscription;
  @override
  final ProviderStatusResponseDto providerStatus;

  factory _$BillingMeResponseDto(
          [void Function(BillingMeResponseDtoBuilder)? updates]) =>
      (BillingMeResponseDtoBuilder()..update(updates))._build();

  _$BillingMeResponseDto._(
      {required this.subscription, required this.providerStatus})
      : super._();
  @override
  BillingMeResponseDto rebuild(
          void Function(BillingMeResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BillingMeResponseDtoBuilder toBuilder() =>
      BillingMeResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BillingMeResponseDto &&
        subscription == other.subscription &&
        providerStatus == other.providerStatus;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, subscription.hashCode);
    _$hash = $jc(_$hash, providerStatus.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BillingMeResponseDto')
          ..add('subscription', subscription)
          ..add('providerStatus', providerStatus))
        .toString();
  }
}

class BillingMeResponseDtoBuilder
    implements Builder<BillingMeResponseDto, BillingMeResponseDtoBuilder> {
  _$BillingMeResponseDto? _$v;

  JsonObject? _subscription;
  JsonObject? get subscription => _$this._subscription;
  set subscription(JsonObject? subscription) =>
      _$this._subscription = subscription;

  ProviderStatusResponseDtoBuilder? _providerStatus;
  ProviderStatusResponseDtoBuilder get providerStatus =>
      _$this._providerStatus ??= ProviderStatusResponseDtoBuilder();
  set providerStatus(ProviderStatusResponseDtoBuilder? providerStatus) =>
      _$this._providerStatus = providerStatus;

  BillingMeResponseDtoBuilder() {
    BillingMeResponseDto._defaults(this);
  }

  BillingMeResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _subscription = $v.subscription;
      _providerStatus = $v.providerStatus.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BillingMeResponseDto other) {
    _$v = other as _$BillingMeResponseDto;
  }

  @override
  void update(void Function(BillingMeResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BillingMeResponseDto build() => _build();

  _$BillingMeResponseDto _build() {
    _$BillingMeResponseDto _$result;
    try {
      _$result = _$v ??
          _$BillingMeResponseDto._(
            subscription: BuiltValueNullFieldError.checkNotNull(
                subscription, r'BillingMeResponseDto', 'subscription'),
            providerStatus: providerStatus.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'providerStatus';
        providerStatus.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BillingMeResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
