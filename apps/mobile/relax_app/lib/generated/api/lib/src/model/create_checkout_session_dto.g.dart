// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_checkout_session_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateCheckoutSessionDtoProviderEnum
    _$createCheckoutSessionDtoProviderEnum_STRIPE =
    const CreateCheckoutSessionDtoProviderEnum._('STRIPE');
const CreateCheckoutSessionDtoProviderEnum
    _$createCheckoutSessionDtoProviderEnum_APP_STORE =
    const CreateCheckoutSessionDtoProviderEnum._('APP_STORE');
const CreateCheckoutSessionDtoProviderEnum
    _$createCheckoutSessionDtoProviderEnum_GOOGLE_PLAY =
    const CreateCheckoutSessionDtoProviderEnum._('GOOGLE_PLAY');
const CreateCheckoutSessionDtoProviderEnum
    _$createCheckoutSessionDtoProviderEnum_MANUAL =
    const CreateCheckoutSessionDtoProviderEnum._('MANUAL');
const CreateCheckoutSessionDtoProviderEnum
    _$createCheckoutSessionDtoProviderEnum_SEPAY =
    const CreateCheckoutSessionDtoProviderEnum._('SEPAY');

CreateCheckoutSessionDtoProviderEnum
    _$createCheckoutSessionDtoProviderEnumValueOf(String name) {
  switch (name) {
    case 'STRIPE':
      return _$createCheckoutSessionDtoProviderEnum_STRIPE;
    case 'APP_STORE':
      return _$createCheckoutSessionDtoProviderEnum_APP_STORE;
    case 'GOOGLE_PLAY':
      return _$createCheckoutSessionDtoProviderEnum_GOOGLE_PLAY;
    case 'MANUAL':
      return _$createCheckoutSessionDtoProviderEnum_MANUAL;
    case 'SEPAY':
      return _$createCheckoutSessionDtoProviderEnum_SEPAY;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreateCheckoutSessionDtoProviderEnum>
    _$createCheckoutSessionDtoProviderEnumValues = BuiltSet<
        CreateCheckoutSessionDtoProviderEnum>(const <CreateCheckoutSessionDtoProviderEnum>[
  _$createCheckoutSessionDtoProviderEnum_STRIPE,
  _$createCheckoutSessionDtoProviderEnum_APP_STORE,
  _$createCheckoutSessionDtoProviderEnum_GOOGLE_PLAY,
  _$createCheckoutSessionDtoProviderEnum_MANUAL,
  _$createCheckoutSessionDtoProviderEnum_SEPAY,
]);

Serializer<CreateCheckoutSessionDtoProviderEnum>
    _$createCheckoutSessionDtoProviderEnumSerializer =
    _$CreateCheckoutSessionDtoProviderEnumSerializer();

class _$CreateCheckoutSessionDtoProviderEnumSerializer
    implements PrimitiveSerializer<CreateCheckoutSessionDtoProviderEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'STRIPE': 'STRIPE',
    'APP_STORE': 'APP_STORE',
    'GOOGLE_PLAY': 'GOOGLE_PLAY',
    'MANUAL': 'MANUAL',
    'SEPAY': 'SEPAY',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'STRIPE': 'STRIPE',
    'APP_STORE': 'APP_STORE',
    'GOOGLE_PLAY': 'GOOGLE_PLAY',
    'MANUAL': 'MANUAL',
    'SEPAY': 'SEPAY',
  };

  @override
  final Iterable<Type> types = const <Type>[
    CreateCheckoutSessionDtoProviderEnum
  ];
  @override
  final String wireName = 'CreateCheckoutSessionDtoProviderEnum';

  @override
  Object serialize(
          Serializers serializers, CreateCheckoutSessionDtoProviderEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreateCheckoutSessionDtoProviderEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreateCheckoutSessionDtoProviderEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreateCheckoutSessionDto extends CreateCheckoutSessionDto {
  @override
  final String planName;
  @override
  final num? amount;
  @override
  final String? currency;
  @override
  final CreateCheckoutSessionDtoProviderEnum? provider;
  @override
  final String? description;
  @override
  final String? successUrl;
  @override
  final String? errorUrl;
  @override
  final String? cancelUrl;

  factory _$CreateCheckoutSessionDto(
          [void Function(CreateCheckoutSessionDtoBuilder)? updates]) =>
      (CreateCheckoutSessionDtoBuilder()..update(updates))._build();

  _$CreateCheckoutSessionDto._(
      {required this.planName,
      this.amount,
      this.currency,
      this.provider,
      this.description,
      this.successUrl,
      this.errorUrl,
      this.cancelUrl})
      : super._();
  @override
  CreateCheckoutSessionDto rebuild(
          void Function(CreateCheckoutSessionDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateCheckoutSessionDtoBuilder toBuilder() =>
      CreateCheckoutSessionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateCheckoutSessionDto &&
        planName == other.planName &&
        amount == other.amount &&
        currency == other.currency &&
        provider == other.provider &&
        description == other.description &&
        successUrl == other.successUrl &&
        errorUrl == other.errorUrl &&
        cancelUrl == other.cancelUrl;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, planName.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, successUrl.hashCode);
    _$hash = $jc(_$hash, errorUrl.hashCode);
    _$hash = $jc(_$hash, cancelUrl.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateCheckoutSessionDto')
          ..add('planName', planName)
          ..add('amount', amount)
          ..add('currency', currency)
          ..add('provider', provider)
          ..add('description', description)
          ..add('successUrl', successUrl)
          ..add('errorUrl', errorUrl)
          ..add('cancelUrl', cancelUrl))
        .toString();
  }
}

class CreateCheckoutSessionDtoBuilder
    implements
        Builder<CreateCheckoutSessionDto, CreateCheckoutSessionDtoBuilder> {
  _$CreateCheckoutSessionDto? _$v;

  String? _planName;
  String? get planName => _$this._planName;
  set planName(String? planName) => _$this._planName = planName;

  num? _amount;
  num? get amount => _$this._amount;
  set amount(num? amount) => _$this._amount = amount;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  CreateCheckoutSessionDtoProviderEnum? _provider;
  CreateCheckoutSessionDtoProviderEnum? get provider => _$this._provider;
  set provider(CreateCheckoutSessionDtoProviderEnum? provider) =>
      _$this._provider = provider;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  String? _successUrl;
  String? get successUrl => _$this._successUrl;
  set successUrl(String? successUrl) => _$this._successUrl = successUrl;

  String? _errorUrl;
  String? get errorUrl => _$this._errorUrl;
  set errorUrl(String? errorUrl) => _$this._errorUrl = errorUrl;

  String? _cancelUrl;
  String? get cancelUrl => _$this._cancelUrl;
  set cancelUrl(String? cancelUrl) => _$this._cancelUrl = cancelUrl;

  CreateCheckoutSessionDtoBuilder() {
    CreateCheckoutSessionDto._defaults(this);
  }

  CreateCheckoutSessionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _planName = $v.planName;
      _amount = $v.amount;
      _currency = $v.currency;
      _provider = $v.provider;
      _description = $v.description;
      _successUrl = $v.successUrl;
      _errorUrl = $v.errorUrl;
      _cancelUrl = $v.cancelUrl;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateCheckoutSessionDto other) {
    _$v = other as _$CreateCheckoutSessionDto;
  }

  @override
  void update(void Function(CreateCheckoutSessionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateCheckoutSessionDto build() => _build();

  _$CreateCheckoutSessionDto _build() {
    final _$result = _$v ??
        _$CreateCheckoutSessionDto._(
          planName: BuiltValueNullFieldError.checkNotNull(
              planName, r'CreateCheckoutSessionDto', 'planName'),
          amount: amount,
          currency: currency,
          provider: provider,
          description: description,
          successUrl: successUrl,
          errorUrl: errorUrl,
          cancelUrl: cancelUrl,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
