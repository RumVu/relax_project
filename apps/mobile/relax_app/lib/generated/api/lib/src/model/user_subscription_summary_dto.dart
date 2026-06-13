//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:relax_api_client/src/model/tier_name_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_subscription_summary_dto.g.dart';

/// UserSubscriptionSummaryDto
///
/// Properties:
/// * [id] 
/// * [planName] 
/// * [status] 
/// * [endDate] 
/// * [tier] 
@BuiltValue()
abstract class UserSubscriptionSummaryDto implements Built<UserSubscriptionSummaryDto, UserSubscriptionSummaryDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'planName')
  String get planName;

  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'endDate')
  DateTime? get endDate;

  @BuiltValueField(wireName: r'tier')
  TierNameDto? get tier;

  UserSubscriptionSummaryDto._();

  factory UserSubscriptionSummaryDto([void updates(UserSubscriptionSummaryDtoBuilder b)]) = _$UserSubscriptionSummaryDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserSubscriptionSummaryDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserSubscriptionSummaryDto> get serializer => _$UserSubscriptionSummaryDtoSerializer();
}

class _$UserSubscriptionSummaryDtoSerializer implements PrimitiveSerializer<UserSubscriptionSummaryDto> {
  @override
  final Iterable<Type> types = const [UserSubscriptionSummaryDto, _$UserSubscriptionSummaryDto];

  @override
  final String wireName = r'UserSubscriptionSummaryDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserSubscriptionSummaryDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'planName';
    yield serializers.serialize(
      object.planName,
      specifiedType: const FullType(String),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'endDate';
    yield object.endDate == null ? null : serializers.serialize(
      object.endDate,
      specifiedType: const FullType.nullable(DateTime),
    );
    if (object.tier != null) {
      yield r'tier';
      yield serializers.serialize(
        object.tier,
        specifiedType: const FullType.nullable(TierNameDto),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserSubscriptionSummaryDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserSubscriptionSummaryDtoBuilder result,
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
        case r'planName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.planName = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'endDate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endDate = valueDes;
          break;
        case r'tier':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(TierNameDto),
          ) as TierNameDto?;
          if (valueDes == null) continue;
          result.tier.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserSubscriptionSummaryDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserSubscriptionSummaryDtoBuilder();
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

