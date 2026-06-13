//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:relax_api_client/src/model/billing_plan_limit_dto.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'billing_plan_response_dto.g.dart';

/// BillingPlanResponseDto
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [title] 
/// * [description] 
/// * [price] 
/// * [currency] 
/// * [billingCycle] 
/// * [features] 
/// * [limits] 
@BuiltValue()
abstract class BillingPlanResponseDto implements Built<BillingPlanResponseDto, BillingPlanResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String? get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'price')
  num get price;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'billingCycle')
  JsonObject? get billingCycle;

  @BuiltValueField(wireName: r'features')
  BuiltList<String> get features;

  @BuiltValueField(wireName: r'limits')
  BuiltList<BillingPlanLimitDto>? get limits;

  BillingPlanResponseDto._();

  factory BillingPlanResponseDto([void updates(BillingPlanResponseDtoBuilder b)]) = _$BillingPlanResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BillingPlanResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BillingPlanResponseDto> get serializer => _$BillingPlanResponseDtoSerializer();
}

class _$BillingPlanResponseDtoSerializer implements PrimitiveSerializer<BillingPlanResponseDto> {
  @override
  final Iterable<Type> types = const [BillingPlanResponseDto, _$BillingPlanResponseDto];

  @override
  final String wireName = r'BillingPlanResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BillingPlanResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.id != null) {
      yield r'id';
      yield serializers.serialize(
        object.id,
        specifiedType: const FullType(String),
      );
    }
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
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType.nullable(String),
      );
    }
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
    if (object.billingCycle != null) {
      yield r'billingCycle';
      yield serializers.serialize(
        object.billingCycle,
        specifiedType: const FullType(JsonObject),
      );
    }
    yield r'features';
    yield serializers.serialize(
      object.features,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
    if (object.limits != null) {
      yield r'limits';
      yield serializers.serialize(
        object.limits,
        specifiedType: const FullType(BuiltList, [FullType(BillingPlanLimitDto)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    BillingPlanResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BillingPlanResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
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
        case r'billingCycle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.billingCycle = valueDes;
          break;
        case r'features':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.features.replace(valueDes);
          break;
        case r'limits':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BillingPlanLimitDto)]),
          ) as BuiltList<BillingPlanLimitDto>;
          result.limits.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BillingPlanResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BillingPlanResponseDtoBuilder();
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

