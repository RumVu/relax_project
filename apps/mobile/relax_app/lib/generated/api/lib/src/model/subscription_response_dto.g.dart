// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SubscriptionResponseDto extends SubscriptionResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final String? tierId;
  @override
  final JsonObject status;
  @override
  final String planName;
  @override
  final num price;
  @override
  final String currency;
  @override
  final DateTime startDate;
  @override
  final DateTime? endDate;
  @override
  final String? externalSubscriptionId;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$SubscriptionResponseDto(
          [void Function(SubscriptionResponseDtoBuilder)? updates]) =>
      (SubscriptionResponseDtoBuilder()..update(updates))._build();

  _$SubscriptionResponseDto._(
      {required this.id,
      required this.userId,
      this.tierId,
      required this.status,
      required this.planName,
      required this.price,
      required this.currency,
      required this.startDate,
      this.endDate,
      this.externalSubscriptionId,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  SubscriptionResponseDto rebuild(
          void Function(SubscriptionResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SubscriptionResponseDtoBuilder toBuilder() =>
      SubscriptionResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubscriptionResponseDto &&
        id == other.id &&
        userId == other.userId &&
        tierId == other.tierId &&
        status == other.status &&
        planName == other.planName &&
        price == other.price &&
        currency == other.currency &&
        startDate == other.startDate &&
        endDate == other.endDate &&
        externalSubscriptionId == other.externalSubscriptionId &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, tierId.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, planName.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, startDate.hashCode);
    _$hash = $jc(_$hash, endDate.hashCode);
    _$hash = $jc(_$hash, externalSubscriptionId.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SubscriptionResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('tierId', tierId)
          ..add('status', status)
          ..add('planName', planName)
          ..add('price', price)
          ..add('currency', currency)
          ..add('startDate', startDate)
          ..add('endDate', endDate)
          ..add('externalSubscriptionId', externalSubscriptionId)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class SubscriptionResponseDtoBuilder
    implements
        Builder<SubscriptionResponseDto, SubscriptionResponseDtoBuilder> {
  _$SubscriptionResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _tierId;
  String? get tierId => _$this._tierId;
  set tierId(String? tierId) => _$this._tierId = tierId;

  JsonObject? _status;
  JsonObject? get status => _$this._status;
  set status(JsonObject? status) => _$this._status = status;

  String? _planName;
  String? get planName => _$this._planName;
  set planName(String? planName) => _$this._planName = planName;

  num? _price;
  num? get price => _$this._price;
  set price(num? price) => _$this._price = price;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  DateTime? _startDate;
  DateTime? get startDate => _$this._startDate;
  set startDate(DateTime? startDate) => _$this._startDate = startDate;

  DateTime? _endDate;
  DateTime? get endDate => _$this._endDate;
  set endDate(DateTime? endDate) => _$this._endDate = endDate;

  String? _externalSubscriptionId;
  String? get externalSubscriptionId => _$this._externalSubscriptionId;
  set externalSubscriptionId(String? externalSubscriptionId) =>
      _$this._externalSubscriptionId = externalSubscriptionId;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  SubscriptionResponseDtoBuilder() {
    SubscriptionResponseDto._defaults(this);
  }

  SubscriptionResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _tierId = $v.tierId;
      _status = $v.status;
      _planName = $v.planName;
      _price = $v.price;
      _currency = $v.currency;
      _startDate = $v.startDate;
      _endDate = $v.endDate;
      _externalSubscriptionId = $v.externalSubscriptionId;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SubscriptionResponseDto other) {
    _$v = other as _$SubscriptionResponseDto;
  }

  @override
  void update(void Function(SubscriptionResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubscriptionResponseDto build() => _build();

  _$SubscriptionResponseDto _build() {
    final _$result = _$v ??
        _$SubscriptionResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'SubscriptionResponseDto', 'id'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'SubscriptionResponseDto', 'userId'),
          tierId: tierId,
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'SubscriptionResponseDto', 'status'),
          planName: BuiltValueNullFieldError.checkNotNull(
              planName, r'SubscriptionResponseDto', 'planName'),
          price: BuiltValueNullFieldError.checkNotNull(
              price, r'SubscriptionResponseDto', 'price'),
          currency: BuiltValueNullFieldError.checkNotNull(
              currency, r'SubscriptionResponseDto', 'currency'),
          startDate: BuiltValueNullFieldError.checkNotNull(
              startDate, r'SubscriptionResponseDto', 'startDate'),
          endDate: endDate,
          externalSubscriptionId: externalSubscriptionId,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'SubscriptionResponseDto', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'SubscriptionResponseDto', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
