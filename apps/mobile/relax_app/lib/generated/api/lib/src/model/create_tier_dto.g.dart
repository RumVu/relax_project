// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_tier_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const CreateTierDtoBillingCycleEnum _$createTierDtoBillingCycleEnum_MONTHLY =
    const CreateTierDtoBillingCycleEnum._('MONTHLY');
const CreateTierDtoBillingCycleEnum _$createTierDtoBillingCycleEnum_ANNUAL =
    const CreateTierDtoBillingCycleEnum._('ANNUAL');

CreateTierDtoBillingCycleEnum _$createTierDtoBillingCycleEnumValueOf(
    String name) {
  switch (name) {
    case 'MONTHLY':
      return _$createTierDtoBillingCycleEnum_MONTHLY;
    case 'ANNUAL':
      return _$createTierDtoBillingCycleEnum_ANNUAL;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<CreateTierDtoBillingCycleEnum>
    _$createTierDtoBillingCycleEnumValues = BuiltSet<
        CreateTierDtoBillingCycleEnum>(const <CreateTierDtoBillingCycleEnum>[
  _$createTierDtoBillingCycleEnum_MONTHLY,
  _$createTierDtoBillingCycleEnum_ANNUAL,
]);

Serializer<CreateTierDtoBillingCycleEnum>
    _$createTierDtoBillingCycleEnumSerializer =
    _$CreateTierDtoBillingCycleEnumSerializer();

class _$CreateTierDtoBillingCycleEnumSerializer
    implements PrimitiveSerializer<CreateTierDtoBillingCycleEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'MONTHLY': 'MONTHLY',
    'ANNUAL': 'ANNUAL',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'MONTHLY': 'MONTHLY',
    'ANNUAL': 'ANNUAL',
  };

  @override
  final Iterable<Type> types = const <Type>[CreateTierDtoBillingCycleEnum];
  @override
  final String wireName = 'CreateTierDtoBillingCycleEnum';

  @override
  Object serialize(
          Serializers serializers, CreateTierDtoBillingCycleEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  CreateTierDtoBillingCycleEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      CreateTierDtoBillingCycleEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$CreateTierDto extends CreateTierDto {
  @override
  final String name;
  @override
  final String? title;
  @override
  final String? description;
  @override
  final num price;
  @override
  final num? salePrice;
  @override
  final String? saleLabel;
  @override
  final String? saleStartsAt;
  @override
  final String? saleEndsAt;
  @override
  final String? currency;
  @override
  final CreateTierDtoBillingCycleEnum billingCycle;
  @override
  final num? displayOrder;
  @override
  final bool? isActive;

  factory _$CreateTierDto([void Function(CreateTierDtoBuilder)? updates]) =>
      (CreateTierDtoBuilder()..update(updates))._build();

  _$CreateTierDto._(
      {required this.name,
      this.title,
      this.description,
      required this.price,
      this.salePrice,
      this.saleLabel,
      this.saleStartsAt,
      this.saleEndsAt,
      this.currency,
      required this.billingCycle,
      this.displayOrder,
      this.isActive})
      : super._();
  @override
  CreateTierDto rebuild(void Function(CreateTierDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateTierDtoBuilder toBuilder() => CreateTierDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateTierDto &&
        name == other.name &&
        title == other.title &&
        description == other.description &&
        price == other.price &&
        salePrice == other.salePrice &&
        saleLabel == other.saleLabel &&
        saleStartsAt == other.saleStartsAt &&
        saleEndsAt == other.saleEndsAt &&
        currency == other.currency &&
        billingCycle == other.billingCycle &&
        displayOrder == other.displayOrder &&
        isActive == other.isActive;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, price.hashCode);
    _$hash = $jc(_$hash, salePrice.hashCode);
    _$hash = $jc(_$hash, saleLabel.hashCode);
    _$hash = $jc(_$hash, saleStartsAt.hashCode);
    _$hash = $jc(_$hash, saleEndsAt.hashCode);
    _$hash = $jc(_$hash, currency.hashCode);
    _$hash = $jc(_$hash, billingCycle.hashCode);
    _$hash = $jc(_$hash, displayOrder.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateTierDto')
          ..add('name', name)
          ..add('title', title)
          ..add('description', description)
          ..add('price', price)
          ..add('salePrice', salePrice)
          ..add('saleLabel', saleLabel)
          ..add('saleStartsAt', saleStartsAt)
          ..add('saleEndsAt', saleEndsAt)
          ..add('currency', currency)
          ..add('billingCycle', billingCycle)
          ..add('displayOrder', displayOrder)
          ..add('isActive', isActive))
        .toString();
  }
}

class CreateTierDtoBuilder
    implements Builder<CreateTierDto, CreateTierDtoBuilder> {
  _$CreateTierDto? _$v;

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

  num? _salePrice;
  num? get salePrice => _$this._salePrice;
  set salePrice(num? salePrice) => _$this._salePrice = salePrice;

  String? _saleLabel;
  String? get saleLabel => _$this._saleLabel;
  set saleLabel(String? saleLabel) => _$this._saleLabel = saleLabel;

  String? _saleStartsAt;
  String? get saleStartsAt => _$this._saleStartsAt;
  set saleStartsAt(String? saleStartsAt) => _$this._saleStartsAt = saleStartsAt;

  String? _saleEndsAt;
  String? get saleEndsAt => _$this._saleEndsAt;
  set saleEndsAt(String? saleEndsAt) => _$this._saleEndsAt = saleEndsAt;

  String? _currency;
  String? get currency => _$this._currency;
  set currency(String? currency) => _$this._currency = currency;

  CreateTierDtoBillingCycleEnum? _billingCycle;
  CreateTierDtoBillingCycleEnum? get billingCycle => _$this._billingCycle;
  set billingCycle(CreateTierDtoBillingCycleEnum? billingCycle) =>
      _$this._billingCycle = billingCycle;

  num? _displayOrder;
  num? get displayOrder => _$this._displayOrder;
  set displayOrder(num? displayOrder) => _$this._displayOrder = displayOrder;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  CreateTierDtoBuilder() {
    CreateTierDto._defaults(this);
  }

  CreateTierDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _name = $v.name;
      _title = $v.title;
      _description = $v.description;
      _price = $v.price;
      _salePrice = $v.salePrice;
      _saleLabel = $v.saleLabel;
      _saleStartsAt = $v.saleStartsAt;
      _saleEndsAt = $v.saleEndsAt;
      _currency = $v.currency;
      _billingCycle = $v.billingCycle;
      _displayOrder = $v.displayOrder;
      _isActive = $v.isActive;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateTierDto other) {
    _$v = other as _$CreateTierDto;
  }

  @override
  void update(void Function(CreateTierDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateTierDto build() => _build();

  _$CreateTierDto _build() {
    final _$result = _$v ??
        _$CreateTierDto._(
          name: BuiltValueNullFieldError.checkNotNull(
              name, r'CreateTierDto', 'name'),
          title: title,
          description: description,
          price: BuiltValueNullFieldError.checkNotNull(
              price, r'CreateTierDto', 'price'),
          salePrice: salePrice,
          saleLabel: saleLabel,
          saleStartsAt: saleStartsAt,
          saleEndsAt: saleEndsAt,
          currency: currency,
          billingCycle: BuiltValueNullFieldError.checkNotNull(
              billingCycle, r'CreateTierDto', 'billingCycle'),
          displayOrder: displayOrder,
          isActive: isActive,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
