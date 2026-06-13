//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:relax_api_client/src/model/checkout_resolved_plan_dto.dart';
import 'package:relax_api_client/src/model/checkout_session_status_dto.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'checkout_session_response_dto.g.dart';

/// CheckoutSessionResponseDto
///
/// Properties:
/// * [configured] 
/// * [provider] 
/// * [tier] - Raw SubscriptionTier row when the plan came from the DB, else null.
/// * [plan] 
/// * [payment] 
/// * [checkout] 
@BuiltValue()
abstract class CheckoutSessionResponseDto implements Built<CheckoutSessionResponseDto, CheckoutSessionResponseDtoBuilder> {
  @BuiltValueField(wireName: r'configured')
  bool get configured;

  @BuiltValueField(wireName: r'provider')
  String get provider;

  /// Raw SubscriptionTier row when the plan came from the DB, else null.
  @BuiltValueField(wireName: r'tier')
  JsonObject get tier;

  @BuiltValueField(wireName: r'plan')
  CheckoutResolvedPlanDto get plan;

  @BuiltValueField(wireName: r'payment')
  JsonObject get payment;

  @BuiltValueField(wireName: r'checkout')
  CheckoutSessionStatusDto get checkout;

  CheckoutSessionResponseDto._();

  factory CheckoutSessionResponseDto([void updates(CheckoutSessionResponseDtoBuilder b)]) = _$CheckoutSessionResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CheckoutSessionResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CheckoutSessionResponseDto> get serializer => _$CheckoutSessionResponseDtoSerializer();
}

class _$CheckoutSessionResponseDtoSerializer implements PrimitiveSerializer<CheckoutSessionResponseDto> {
  @override
  final Iterable<Type> types = const [CheckoutSessionResponseDto, _$CheckoutSessionResponseDto];

  @override
  final String wireName = r'CheckoutSessionResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CheckoutSessionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'configured';
    yield serializers.serialize(
      object.configured,
      specifiedType: const FullType(bool),
    );
    yield r'provider';
    yield serializers.serialize(
      object.provider,
      specifiedType: const FullType(String),
    );
    yield r'tier';
    yield serializers.serialize(
      object.tier,
      specifiedType: const FullType(JsonObject),
    );
    yield r'plan';
    yield serializers.serialize(
      object.plan,
      specifiedType: const FullType(CheckoutResolvedPlanDto),
    );
    yield r'payment';
    yield serializers.serialize(
      object.payment,
      specifiedType: const FullType(JsonObject),
    );
    yield r'checkout';
    yield serializers.serialize(
      object.checkout,
      specifiedType: const FullType(CheckoutSessionStatusDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CheckoutSessionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CheckoutSessionResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'configured':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.configured = valueDes;
          break;
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.provider = valueDes;
          break;
        case r'tier':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.tier = valueDes;
          break;
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CheckoutResolvedPlanDto),
          ) as CheckoutResolvedPlanDto;
          result.plan.replace(valueDes);
          break;
        case r'payment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.payment = valueDes;
          break;
        case r'checkout':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CheckoutSessionStatusDto),
          ) as CheckoutSessionStatusDto;
          result.checkout.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CheckoutSessionResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CheckoutSessionResponseDtoBuilder();
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

