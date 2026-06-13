//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'billing_plan_limit_dto.g.dart';

/// BillingPlanLimitDto
///
/// Properties:
/// * [name] 
/// * [value] 
/// * [unit] 
@BuiltValue()
abstract class BillingPlanLimitDto implements Built<BillingPlanLimitDto, BillingPlanLimitDtoBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'value')
  num get value;

  @BuiltValueField(wireName: r'unit')
  String? get unit;

  BillingPlanLimitDto._();

  factory BillingPlanLimitDto([void updates(BillingPlanLimitDtoBuilder b)]) = _$BillingPlanLimitDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BillingPlanLimitDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BillingPlanLimitDto> get serializer => _$BillingPlanLimitDtoSerializer();
}

class _$BillingPlanLimitDtoSerializer implements PrimitiveSerializer<BillingPlanLimitDto> {
  @override
  final Iterable<Type> types = const [BillingPlanLimitDto, _$BillingPlanLimitDto];

  @override
  final String wireName = r'BillingPlanLimitDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BillingPlanLimitDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'value';
    yield serializers.serialize(
      object.value,
      specifiedType: const FullType(num),
    );
    yield r'unit';
    yield object.unit == null ? null : serializers.serialize(
      object.unit,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BillingPlanLimitDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BillingPlanLimitDtoBuilder result,
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
        case r'value':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.value = valueDes;
          break;
        case r'unit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.unit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BillingPlanLimitDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BillingPlanLimitDtoBuilder();
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

