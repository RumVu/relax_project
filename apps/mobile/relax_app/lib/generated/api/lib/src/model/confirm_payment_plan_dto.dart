//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'confirm_payment_plan_dto.g.dart';

/// ConfirmPaymentPlanDto
///
/// Properties:
/// * [name] 
/// * [title] 
/// * [price] 
/// * [currency] 
/// * [source_] 
@BuiltValue()
abstract class ConfirmPaymentPlanDto implements Built<ConfirmPaymentPlanDto, ConfirmPaymentPlanDtoBuilder> {
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

  ConfirmPaymentPlanDto._();

  factory ConfirmPaymentPlanDto([void updates(ConfirmPaymentPlanDtoBuilder b)]) = _$ConfirmPaymentPlanDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConfirmPaymentPlanDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConfirmPaymentPlanDto> get serializer => _$ConfirmPaymentPlanDtoSerializer();
}

class _$ConfirmPaymentPlanDtoSerializer implements PrimitiveSerializer<ConfirmPaymentPlanDto> {
  @override
  final Iterable<Type> types = const [ConfirmPaymentPlanDto, _$ConfirmPaymentPlanDto];

  @override
  final String wireName = r'ConfirmPaymentPlanDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConfirmPaymentPlanDto object, {
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
    ConfirmPaymentPlanDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConfirmPaymentPlanDtoBuilder result,
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
  ConfirmPaymentPlanDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConfirmPaymentPlanDtoBuilder();
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

