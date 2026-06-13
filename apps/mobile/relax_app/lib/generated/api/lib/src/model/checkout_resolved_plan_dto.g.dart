// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_resolved_plan_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CheckoutResolvedPlanDto extends CheckoutResolvedPlanDto {
  @override
  final String name;
  @override
  final String title;
  @override
  final num price;
  @override
  final String currency;
  @override
  final String source_;

  factory _$CheckoutResolvedPlanDto(
          [void Function(CheckoutResolvedPlanDtoBuilder)? updates]) =>
      (CheckoutResolvedPlanDtoBuilder()..update(updates))._build();

  _$CheckoutResolvedPlanDto._(
      {required this.name,
      required this.title,
      required this.price,
      required this.currency,
      required this.source_})
      : super._();
  @override
  CheckoutResolvedPlanDto rebuild(
          void Function(CheckoutResolvedPlanDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CheckoutResolvedPlanDtoBuilder toBuilder() =>
      CheckoutResolvedPlanDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CheckoutResolvedPlanDto &&
        name == other.name &&
        title == other.title &&
        price == other.price &&
        currency == other.currency &&
        source_ == other.source_;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, source_.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CheckoutResolvedPlanDto')
          ..add('name', name)
          ..add('title', title)
          ..add('price', price)
          ..add('currency', currency)
          ..add('source_', source_))
        .toString();
  }
}

class CheckoutResolvedPlanDtoBuilder
    implements
        Builder<CheckoutResolvedPlanDto, CheckoutResolvedPlanDtoBuilder> {
  _$CheckoutResolvedPlanDto? _$v;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  num? _price;
  num? get price => _$this._price;
  set price(num? price) => _$this._price = price;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  String? _source_;
  String? get source_ => _$this._source_;
  set source_(String? source_) => _$this._source_ = source_;

  CheckoutResolvedPlanDtoBuilder() {
    CheckoutResolvedPlanDto._defaults(this);
  }

  CheckoutResolvedPlanDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _title = $v.title;
      _price = $v.price;
      _currency = $v.currency;
      _source_ = $v.source_;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CheckoutResolvedPlanDto other) {
    _$v = other as _$CheckoutResolvedPlanDto;
  }

  @override
  void update(void Function(CheckoutResolvedPlanDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CheckoutResolvedPlanDto build() => _build();

  _$CheckoutResolvedPlanDto _build() {
    final _$result = _$v ??
        _$CheckoutResolvedPlanDto._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'CheckoutResolvedPlanDto', 'name'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'CheckoutResolvedPlanDto', 'title'),
          price: BuiltValueNullFieldError.checkNotNull(
              price, r'CheckoutResolvedPlanDto', 'price'),
          currency: BuiltValueNullFieldError.checkNotNull(
              currency, r'CheckoutResolvedPlanDto', 'currency'),
          source_: BuiltValueNullFieldError.checkNotNull(
              source_, r'CheckoutResolvedPlanDto', 'source_'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
