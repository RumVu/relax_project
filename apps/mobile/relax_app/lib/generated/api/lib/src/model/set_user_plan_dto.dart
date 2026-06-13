//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'set_user_plan_dto.g.dart';

/// SetUserPlanDto
///
/// Properties:
/// * [planName] - Tier code (UPPER_SNAKE) matching one of the rows from /admin/billing/tiers. E.g. \"FREE\", \"CHILL_PLUS\".
@BuiltValue()
abstract class SetUserPlanDto implements Built<SetUserPlanDto, SetUserPlanDtoBuilder> {
  /// Tier code (UPPER_SNAKE) matching one of the rows from /admin/billing/tiers. E.g. \"FREE\", \"CHILL_PLUS\".
  @BuiltValueField(wireName: r'planName')
  String get planName;

  SetUserPlanDto._();

  factory SetUserPlanDto([void updates(SetUserPlanDtoBuilder b)]) = _$SetUserPlanDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SetUserPlanDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SetUserPlanDto> get serializer => _$SetUserPlanDtoSerializer();
}

class _$SetUserPlanDtoSerializer implements PrimitiveSerializer<SetUserPlanDto> {
  @override
  final Iterable<Type> types = const [SetUserPlanDto, _$SetUserPlanDto];

  @override
  final String wireName = r'SetUserPlanDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SetUserPlanDto object, {
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
    SetUserPlanDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SetUserPlanDtoBuilder result,
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
  SetUserPlanDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SetUserPlanDtoBuilder();
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

