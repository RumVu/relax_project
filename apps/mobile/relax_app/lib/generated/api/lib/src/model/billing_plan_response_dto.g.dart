// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'billing_plan_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$BillingPlanResponseDto extends BillingPlanResponseDto {
  @override
  final String? id;
  @override
  final String name;
  @override
  final String title;
  @override
  final String? description;
  @override
  final num price;
  @override
  final String currency;
  @override
  final JsonObject? billingCycle;
  @override
  final BuiltList<String> features;
  @override
  final BuiltList<BillingPlanLimitDto>? limits;

  factory _$BillingPlanResponseDto(
          [void Function(BillingPlanResponseDtoBuilder)? updates]) =>
      (BillingPlanResponseDtoBuilder()..update(updates))._build();

  _$BillingPlanResponseDto._(
      {this.id,
      required this.name,
      required this.title,
      this.description,
      required this.price,
      required this.currency,
      this.billingCycle,
      required this.features,
      this.limits})
      : super._();
  @override
  BillingPlanResponseDto rebuild(
          void Function(BillingPlanResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  BillingPlanResponseDtoBuilder toBuilder() =>
      BillingPlanResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is BillingPlanResponseDto &&
        id == other.id &&
        name == other.name &&
        title == other.title &&
        description == other.description &&
        price == other.price &&
        currency == other.currency &&
        billingCycle == other.billingCycle &&
        features == other.features &&
        limits == other.limits;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, billingCycle.hashCode);
    _$hash = $jc(_$hash, features.hashCode);
    _$hash = $jc(_$hash, limits.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'BillingPlanResponseDto')
          ..add('id', id)
          ..add('name', name)
          ..add('title', title)
          ..add('description', description)
          ..add('price', price)
          ..add('currency', currency)
          ..add('billingCycle', billingCycle)
          ..add('features', features)
          ..add('limits', limits))
        .toString();
  }
}

class BillingPlanResponseDtoBuilder
    implements Builder<BillingPlanResponseDto, BillingPlanResponseDtoBuilder> {
  _$BillingPlanResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  num? _price;
  num? get price => _$this._price;
  set price(num? price) => _$this._price = price;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  JsonObject? _billingCycle;
  JsonObject? get billingCycle => _$this._billingCycle;
  set billingCycle(JsonObject? billingCycle) =>
      _$this._billingCycle = billingCycle;

  ListBuilder<String>? _features;
  ListBuilder<String> get features =>
      _$this._features ??= ListBuilder<String>();
  set features(ListBuilder<String>? features) => _$this._features = features;

  ListBuilder<BillingPlanLimitDto>? _limits;
  ListBuilder<BillingPlanLimitDto> get limits =>
      _$this._limits ??= ListBuilder<BillingPlanLimitDto>();
  set limits(ListBuilder<BillingPlanLimitDto>? limits) =>
      _$this._limits = limits;

  BillingPlanResponseDtoBuilder() {
    BillingPlanResponseDto._defaults(this);
  }

  BillingPlanResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _name = $v.name;
      _title = $v.title;
      _description = $v.description;
      _price = $v.price;
      _currency = $v.currency;
      _billingCycle = $v.billingCycle;
      _features = $v.features.toBuilder();
      _limits = $v.limits?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(BillingPlanResponseDto other) {
    _$v = other as _$BillingPlanResponseDto;
  }

  @override
  void update(void Function(BillingPlanResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  BillingPlanResponseDto build() => _build();

  _$BillingPlanResponseDto _build() {
    _$BillingPlanResponseDto _$result;
    try {
      _$result = _$v ??
          _$BillingPlanResponseDto._(
            id: id,
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'BillingPlanResponseDto', 'name'),
            title: BuiltValueNullFieldError.checkNotNull(
                title, r'BillingPlanResponseDto', 'title'),
            description: description,
            price: BuiltValueNullFieldError.checkNotNull(
                price, r'BillingPlanResponseDto', 'price'),
            currency: BuiltValueNullFieldError.checkNotNull(
                currency, r'BillingPlanResponseDto', 'currency'),
            billingCycle: billingCycle,
            features: features.build(),
            limits: _limits?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'features';
        features.build();
        _$failedField = 'limits';
        _limits?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'BillingPlanResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
