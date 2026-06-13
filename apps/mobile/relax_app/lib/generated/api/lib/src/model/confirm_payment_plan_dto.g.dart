// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_payment_plan_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConfirmPaymentPlanDto extends ConfirmPaymentPlanDto {
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

  factory _$ConfirmPaymentPlanDto(
          [void Function(ConfirmPaymentPlanDtoBuilder)? updates]) =>
      (ConfirmPaymentPlanDtoBuilder()..update(updates))._build();

  _$ConfirmPaymentPlanDto._(
      {required this.name,
      required this.title,
      required this.price,
      required this.currency,
      required this.source_})
      : super._();
  @override
  ConfirmPaymentPlanDto rebuild(
          void Function(ConfirmPaymentPlanDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConfirmPaymentPlanDtoBuilder toBuilder() =>
      ConfirmPaymentPlanDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConfirmPaymentPlanDto &&
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
    return (newBuiltValueToStringHelper(r'ConfirmPaymentPlanDto')
          ..add('name', name)
          ..add('title', title)
          ..add('price', price)
          ..add('currency', currency)
          ..add('source_', source_))
        .toString();
  }
}

class ConfirmPaymentPlanDtoBuilder
    implements Builder<ConfirmPaymentPlanDto, ConfirmPaymentPlanDtoBuilder> {
  _$ConfirmPaymentPlanDto? _$v;

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

  ConfirmPaymentPlanDtoBuilder() {
    ConfirmPaymentPlanDto._defaults(this);
  }

  ConfirmPaymentPlanDtoBuilder get _$this {
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
  void replace(ConfirmPaymentPlanDto other) {
    _$v = other as _$ConfirmPaymentPlanDto;
  }

  @override
  void update(void Function(ConfirmPaymentPlanDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConfirmPaymentPlanDto build() => _build();

  _$ConfirmPaymentPlanDto _build() {
    final _$result = _$v ??
        _$ConfirmPaymentPlanDto._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'ConfirmPaymentPlanDto', 'name'),
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'ConfirmPaymentPlanDto', 'title'),
          price: BuiltValueNullFieldError.checkNotNull(
              price, r'ConfirmPaymentPlanDto', 'price'),
          currency: BuiltValueNullFieldError.checkNotNull(
              currency, r'ConfirmPaymentPlanDto', 'currency'),
          source_: BuiltValueNullFieldError.checkNotNull(
              source_, r'ConfirmPaymentPlanDto', 'source_'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
