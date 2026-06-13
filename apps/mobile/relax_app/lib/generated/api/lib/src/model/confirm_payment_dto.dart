//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'confirm_payment_dto.g.dart';

/// ConfirmPaymentDto
///
/// Properties:
/// * [planName] - Plan the pending payment was created for. The backend re-resolves the plan from SubscriptionTier/fallback catalog and verifies the paid amount matches before activating the subscription.
@BuiltValue()
abstract class ConfirmPaymentDto implements Built<ConfirmPaymentDto, ConfirmPaymentDtoBuilder> {
  /// Plan the pending payment was created for. The backend re-resolves the plan from SubscriptionTier/fallback catalog and verifies the paid amount matches before activating the subscription.
  @BuiltValueField(wireName: r'planName')
  String get planName;

  ConfirmPaymentDto._();

  factory ConfirmPaymentDto([void updates(ConfirmPaymentDtoBuilder b)]) = _$ConfirmPaymentDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ConfirmPaymentDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ConfirmPaymentDto> get serializer => _$ConfirmPaymentDtoSerializer();
}

class _$ConfirmPaymentDtoSerializer implements PrimitiveSerializer<ConfirmPaymentDto> {
  @override
  final Iterable<Type> types = const [ConfirmPaymentDto, _$ConfirmPaymentDto];

  @override
  final String wireName = r'ConfirmPaymentDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ConfirmPaymentDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'planName';
    yield serializers.serialize(
      object.planName,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ConfirmPaymentDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ConfirmPaymentDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'planName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.planName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ConfirmPaymentDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ConfirmPaymentDtoBuilder();
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

