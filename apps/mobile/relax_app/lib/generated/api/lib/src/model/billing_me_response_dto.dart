//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:relax_api_client/src/model/provider_status_response_dto.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'billing_me_response_dto.g.dart';

/// BillingMeResponseDto
///
/// Properties:
/// * [subscription] - Either the latest real Subscription row or a synthetic FREE placeholder.
/// * [providerStatus] 
@BuiltValue()
abstract class BillingMeResponseDto implements Built<BillingMeResponseDto, BillingMeResponseDtoBuilder> {
  /// Either the latest real Subscription row or a synthetic FREE placeholder.
  @BuiltValueField(wireName: r'subscription')
  JsonObject get subscription;

  @BuiltValueField(wireName: r'providerStatus')
  ProviderStatusResponseDto get providerStatus;

  BillingMeResponseDto._();

  factory BillingMeResponseDto([void updates(BillingMeResponseDtoBuilder b)]) = _$BillingMeResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BillingMeResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BillingMeResponseDto> get serializer => _$BillingMeResponseDtoSerializer();
}

class _$BillingMeResponseDtoSerializer implements PrimitiveSerializer<BillingMeResponseDto> {
  @override
  final Iterable<Type> types = const [BillingMeResponseDto, _$BillingMeResponseDto];

  @override
  final String wireName = r'BillingMeResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BillingMeResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'subscription';
    yield serializers.serialize(
      object.subscription,
      specifiedType: const FullType(JsonObject),
    );
    yield r'providerStatus';
    yield serializers.serialize(
      object.providerStatus,
      specifiedType: const FullType(ProviderStatusResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BillingMeResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BillingMeResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'subscription':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.subscription = valueDes;
          break;
        case r'providerStatus':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ProviderStatusResponseDto),
          ) as ProviderStatusResponseDto;
          result.providerStatus.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BillingMeResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BillingMeResponseDtoBuilder();
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

