//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'subscription_response_dto.g.dart';

/// SubscriptionResponseDto
///
/// Properties:
/// * [id] 
/// * [userId] 
/// * [tierId] 
/// * [status] 
/// * [planName] 
/// * [price] 
/// * [currency] 
/// * [startDate] 
/// * [endDate] 
/// * [externalSubscriptionId] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class SubscriptionResponseDto implements Built<SubscriptionResponseDto, SubscriptionResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'tierId')
  String? get tierId;

  @BuiltValueField(wireName: r'status')
  JsonObject get status;

  @BuiltValueField(wireName: r'planName')
  String get planName;

  @BuiltValueField(wireName: r'price')
  num get price;

  @BuiltValueField(wireName: r'currency')
  String get currency;

  @BuiltValueField(wireName: r'startDate')
  DateTime get startDate;

  @BuiltValueField(wireName: r'endDate')
  DateTime? get endDate;

  @BuiltValueField(wireName: r'externalSubscriptionId')
  String? get externalSubscriptionId;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  SubscriptionResponseDto._();

  factory SubscriptionResponseDto([void updates(SubscriptionResponseDtoBuilder b)]) = _$SubscriptionResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SubscriptionResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SubscriptionResponseDto> get serializer => _$SubscriptionResponseDtoSerializer();
}

class _$SubscriptionResponseDtoSerializer implements PrimitiveSerializer<SubscriptionResponseDto> {
  @override
  final Iterable<Type> types = const [SubscriptionResponseDto, _$SubscriptionResponseDto];

  @override
  final String wireName = r'SubscriptionResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SubscriptionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'userId';
    yield serializers.serialize(
      object.userId,
      specifiedType: const FullType(String),
    );
    yield r'tierId';
    yield object.tierId == null ? null : serializers.serialize(
      object.tierId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(JsonObject),
    );
    yield r'planName';
    yield serializers.serialize(
      object.planName,
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
    yield r'startDate';
    yield serializers.serialize(
      object.startDate,
      specifiedType: const FullType(DateTime),
    );
    yield r'endDate';
    yield object.endDate == null ? null : serializers.serialize(
      object.endDate,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'externalSubscriptionId';
    yield object.externalSubscriptionId == null ? null : serializers.serialize(
      object.externalSubscriptionId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    SubscriptionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SubscriptionResponseDtoBuilder result,
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
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'tierId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.tierId = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.status = valueDes;
          break;
        case r'planName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.planName = valueDes;
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
        case r'startDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startDate = valueDes;
          break;
        case r'endDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endDate = valueDes;
          break;
        case r'externalSubscriptionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.externalSubscriptionId = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SubscriptionResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SubscriptionResponseDtoBuilder();
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

