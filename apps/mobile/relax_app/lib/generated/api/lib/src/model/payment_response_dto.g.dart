// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$PaymentResponseDto extends PaymentResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final num amount;
  @override
  final String currency;
  @override
  final JsonObject status;
  @override
  final String? provider;
  @override
  final String? method;
  @override
  final String? description;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$PaymentResponseDto(
          [void Function(PaymentResponseDtoBuilder)? updates]) =>
      (PaymentResponseDtoBuilder()..update(updates))._build();

  _$PaymentResponseDto._(
      {required this.id,
      required this.userId,
      required this.amount,
      required this.currency,
      required this.status,
      this.provider,
      this.method,
      this.description,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  PaymentResponseDto rebuild(
          void Function(PaymentResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  PaymentResponseDtoBuilder toBuilder() =>
      PaymentResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is PaymentResponseDto &&
        id == other.id &&
        userId == other.userId &&
        amount == other.amount &&
        currency == other.currency &&
        status == other.status &&
        provider == other.provider &&
        method == other.method &&
        description == other.description &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, method.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'PaymentResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('amount', amount)
          ..add('currency', currency)
          ..add('status', status)
          ..add('provider', provider)
          ..add('method', method)
          ..add('description', description)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class PaymentResponseDtoBuilder
    implements Builder<PaymentResponseDto, PaymentResponseDtoBuilder> {
  _$PaymentResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  num? _amount;
  num? get amount => _$this._amount;
  set amount(num? amount) => _$this._amount = amount;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  JsonObject? _status;
  JsonObject? get status => _$this._status;
  set status(JsonObject? status) => _$this._status = status;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  String? _method;
  String? get method => _$this._method;
  set method(String? method) => _$this._method = method;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  PaymentResponseDtoBuilder() {
    PaymentResponseDto._defaults(this);
  }

  PaymentResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _amount = $v.amount;
      _currency = $v.currency;
      _status = $v.status;
      _provider = $v.provider;
      _method = $v.method;
      _description = $v.description;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(PaymentResponseDto other) {
    _$v = other as _$PaymentResponseDto;
  }

  @override
  void update(void Function(PaymentResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  PaymentResponseDto build() => _build();

  _$PaymentResponseDto _build() {
    final _$result = _$v ??
        _$PaymentResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'PaymentResponseDto', 'id'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'PaymentResponseDto', 'userId'),
          amount: BuiltValueNullFieldError.checkNotNull(
              amount, r'PaymentResponseDto', 'amount'),
          currency: BuiltValueNullFieldError.checkNotNull(
              currency, r'PaymentResponseDto', 'currency'),
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'PaymentResponseDto', 'status'),
          provider: provider,
          method: method,
          description: description,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'PaymentResponseDto', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'PaymentResponseDto', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
