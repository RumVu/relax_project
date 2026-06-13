//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'checkout_resolved_plan_dto.g.dart';

/// CheckoutResolvedPlanDto
///
/// Properties:
/// * [name] 
/// * [title] 
/// * [price] 
/// * [currency] 
/// * [source_] 
@BuiltValue()
abstract class CheckoutResolvedPlanDto implements Built<CheckoutResolvedPlanDto, CheckoutResolvedPlanDtoBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'price')
  num get price;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'source')
  String get source_;

  CheckoutResolvedPlanDto._();

  factory CheckoutResolvedPlanDto([void updates(CheckoutResolvedPlanDtoBuilder b)]) = _$CheckoutResolvedPlanDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CheckoutResolvedPlanDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CheckoutResolvedPlanDto> get serializer => _$CheckoutResolvedPlanDtoSerializer();
}

class _$CheckoutResolvedPlanDtoSerializer implements PrimitiveSerializer<CheckoutResolvedPlanDto> {
  @override
  final Iterable<Type> types = const [CheckoutResolvedPlanDto, _$CheckoutResolvedPlanDto];

  @override
  final String wireName = r'CheckoutResolvedPlanDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CheckoutResolvedPlanDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'price';
    yield serializers.serialize(
      object.price,
      specifiedType: const FullType(num),
    );
    yield r'currency';
    yield serializers.serialize(
      object.currency,
      specifiedType: const FullType(String),
    );
    yield r'source';
    yield serializers.serialize(
      object.source_,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CheckoutResolvedPlanDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CheckoutResolvedPlanDtoBuilder result,
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
        case r'price':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.price = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'source':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.source_ = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CheckoutResolvedPlanDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CheckoutResolvedPlanDtoBuilder();
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

