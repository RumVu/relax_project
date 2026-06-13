//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:relax_api_client/src/model/confirm_payment_plan_dto.dart';
import 'package:relax_api_client/src/model/payment_response_dto.dart';
import 'package:relax_api_client/src/model/subscription_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'confirm_payment_response_dto.g.dart';

/// ConfirmPaymentResponseDto
///
/// Properties:
/// * [payment] 
/// * [subscription] 
/// * [plan] 
@BuiltValue()
abstract class ConfirmPaymentResponseDto implements Built<ConfirmPaymentResponseDto, ConfirmPaymentResponseDtoBuilder> {
  @BuiltValueField(wireName: r'payment')
  PaymentResponseDto get payment;

  @BuiltValueField(wireName: r'subscription')
  SubscriptionResponseDto get subscription;

  @BuiltValueField(wireName: r'plan')
  ConfirmPaymentPlanDto get plan;

  ConfirmPaymentResponseDto._();

  factory ConfirmPaymentResponseDto([void updates(ConfirmPaymentResponseDtoBuilder b)]) = _$ConfirmPaymentResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConfirmPaymentResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConfirmPaymentResponseDto> get serializer => _$ConfirmPaymentResponseDtoSerializer();
}

class _$ConfirmPaymentResponseDtoSerializer implements PrimitiveSerializer<ConfirmPaymentResponseDto> {
  @override
  final Iterable<Type> types = const [ConfirmPaymentResponseDto, _$ConfirmPaymentResponseDto];

  @override
  final String wireName = r'ConfirmPaymentResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConfirmPaymentResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'payment';
    yield serializers.serialize(
      object.payment,
      specifiedType: const FullType(PaymentResponseDto),
    );
    yield r'subscription';
    yield serializers.serialize(
      object.subscription,
      specifiedType: const FullType(SubscriptionResponseDto),
    );
    yield r'plan';
    yield serializers.serialize(
      object.plan,
      specifiedType: const FullType(ConfirmPaymentPlanDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ConfirmPaymentResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConfirmPaymentResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'payment':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(PaymentResponseDto),
          ) as PaymentResponseDto;
          result.payment.replace(valueDes);
          break;
        case r'subscription':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(SubscriptionResponseDto),
          ) as SubscriptionResponseDto;
          result.subscription.replace(valueDes);
          break;
        case r'plan':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ConfirmPaymentPlanDto),
          ) as ConfirmPaymentPlanDto;
          result.plan.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConfirmPaymentResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConfirmPaymentResponseDtoBuilder();
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

