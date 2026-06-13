//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_tier_dto.g.dart';

/// UpdateTierDto
///
/// Properties:
/// * [name] - Unique internal code, UPPER_SNAKE only. E.g. CHILL_PLUS, CHILL_PLUS_ANNUAL.
/// * [title] - Display title shown to users. Falls back to name when null.
/// * [description] - Marketing copy / description.
/// * [price] - List price in the smallest visible unit (e.g. VND).
/// * [salePrice] - Active sale price. Effective when within sale window.
/// * [saleLabel] - Short label shown beside the sale price, e.g. \"BLACK FRIDAY -20%\".
/// * [saleStartsAt] - ISO datetime when the sale starts.
/// * [saleEndsAt] - ISO datetime when the sale ends.
/// * [currency] - ISO 4217 currency. Defaults to VND.
/// * [billingCycle] 
/// * [displayOrder] - Display order, low to high.
/// * [isActive] 
@BuiltValue()
abstract class UpdateTierDto implements Built<UpdateTierDto, UpdateTierDtoBuilder> {
  /// Unique internal code, UPPER_SNAKE only. E.g. CHILL_PLUS, CHILL_PLUS_ANNUAL.
  @BuiltValueField(wireName: r'name')
  String? get name;

  /// Display title shown to users. Falls back to name when null.
  @BuiltValueField(wireName: r'title')
  String? get title;

  /// Marketing copy / description.
  @BuiltValueField(wireName: r'description')
  String? get description;

  /// List price in the smallest visible unit (e.g. VND).
  @BuiltValueField(wireName: r'price')
  num? get price;

  /// Active sale price. Effective when within sale window.
  @BuiltValueField(wireName: r'salePrice')
  num? get salePrice;

  /// Short label shown beside the sale price, e.g. \"BLACK FRIDAY -20%\".
  @BuiltValueField(wireName: r'saleLabel')
  String? get saleLabel;

  /// ISO datetime when the sale starts.
  @BuiltValueField(wireName: r'saleStartsAt')
  String? get saleStartsAt;

  /// ISO datetime when the sale ends.
  @BuiltValueField(wireName: r'saleEndsAt')
  String? get saleEndsAt;

  /// ISO 4217 currency. Defaults to VND.
  @BuiltValueField(wireName: r'currency')
  String? get currency;

  @BuiltValueField(wireName: r'billingCycle')
  UpdateTierDtoBillingCycleEnum? get billingCycle;
  // enum billingCycleEnum {  MONTHLY,  ANNUAL,  };

  /// Display order, low to high.
  @BuiltValueField(wireName: r'displayOrder')
  num? get displayOrder;

  @BuiltValueField(wireName: r'isActive')
  bool? get isActive;

  UpdateTierDto._();

  factory UpdateTierDto([void updates(UpdateTierDtoBuilder b)]) = _$UpdateTierDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateTierDtoBuilder b) => b
      ..displayOrder = 0
      ..isActive = true;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateTierDto> get serializer => _$UpdateTierDtoSerializer();
}

class _$UpdateTierDtoSerializer implements PrimitiveSerializer<UpdateTierDto> {
  @override
  final Iterable<Type> types = const [UpdateTierDto, _$UpdateTierDto];

  @override
  final String wireName = r'UpdateTierDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateTierDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    if (object.price != null) {
      yield r'price';
      yield serializers.serialize(
        object.price,
        specifiedType: const FullType(num),
      );
    }
    if (object.salePrice != null) {
      yield r'salePrice';
      yield serializers.serialize(
        object.salePrice,
        specifiedType: const FullType(num),
      );
    }
    if (object.saleLabel != null) {
      yield r'saleLabel';
      yield serializers.serialize(
        object.saleLabel,
        specifiedType: const FullType(String),
      );
    }
    if (object.saleStartsAt != null) {
      yield r'saleStartsAt';
      yield serializers.serialize(
        object.saleStartsAt,
        specifiedType: const FullType(String),
      );
    }
    if (object.saleEndsAt != null) {
      yield r'saleEndsAt';
      yield serializers.serialize(
        object.saleEndsAt,
        specifiedType: const FullType(String),
      );
    }
    if (object.currency != null) {
      yield r'currency';
      yield serializers.serialize(
        object.currency,
        specifiedType: const FullType(String),
      );
    }
    if (object.billingCycle != null) {
      yield r'billingCycle';
      yield serializers.serialize(
        object.billingCycle,
        specifiedType: const FullType(UpdateTierDtoBillingCycleEnum),
      );
    }
    if (object.displayOrder != null) {
      yield r'displayOrder';
      yield serializers.serialize(
        object.displayOrder,
        specifiedType: const FullType(num),
      );
    }
    if (object.isActive != null) {
      yield r'isActive';
      yield serializers.serialize(
        object.isActive,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateTierDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateTierDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.price = valueDes;
          break;
        case r'salePrice':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.salePrice = valueDes;
          break;
        case r'saleLabel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.saleLabel = valueDes;
          break;
        case r'saleStartsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.saleStartsAt = valueDes;
          break;
        case r'saleEndsAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.saleEndsAt = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'billingCycle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UpdateTierDtoBillingCycleEnum),
          ) as UpdateTierDtoBillingCycleEnum;
          result.billingCycle = valueDes;
          break;
        case r'displayOrder':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.displayOrder = valueDes;
          break;
        case r'isActive':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isActive = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateTierDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateTierDtoBuilder();
    final serializedList = (serialized as Iterable<Object?>).toList();
    final unhandled = <Object?>[];
    _deserializeProperties(
      serializers,
      serialized,
      specifiedType: specifiedType,
      serializedList: serializedList,
      unhandled: unhandled,
      result: result,
    );
    return result.build();
  }
}

class UpdateTierDtoBillingCycleEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'MONTHLY')
  static const UpdateTierDtoBillingCycleEnum MONTHLY = _$updateTierDtoBillingCycleEnum_MONTHLY;
  @BuiltValueEnumConst(wireName: r'ANNUAL')
  static const UpdateTierDtoBillingCycleEnum ANNUAL = _$updateTierDtoBillingCycleEnum_ANNUAL;

  static Serializer<UpdateTierDtoBillingCycleEnum> get serializer => _$updateTierDtoBillingCycleEnumSerializer;

  const UpdateTierDtoBillingCycleEnum._(String name): super(name);

  static BuiltSet<UpdateTierDtoBillingCycleEnum> get values => _$updateTierDtoBillingCycleEnumValues;
  static UpdateTierDtoBillingCycleEnum valueOf(String name) => _$updateTierDtoBillingCycleEnumValueOf(name);
}

