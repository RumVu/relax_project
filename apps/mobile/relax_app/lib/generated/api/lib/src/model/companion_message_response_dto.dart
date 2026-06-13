//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'companion_message_response_dto.g.dart';

/// CompanionMessageResponseDto
///
/// Properties:
/// * [id] 
/// * [content] 
/// * [triggerType] 
/// * [mood] 
/// * [companionMood] 
/// * [minHour] 
/// * [maxHour] 
/// * [weight] 
/// * [isActive] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class CompanionMessageResponseDto implements Built<CompanionMessageResponseDto, CompanionMessageResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'content')
  String get content;

  @BuiltValueField(wireName: r'triggerType')
  JsonObject get triggerType;

  @BuiltValueField(wireName: r'mood')
  JsonObject? get mood;

  @BuiltValueField(wireName: r'companionMood')
  JsonObject? get companionMood;

  @BuiltValueField(wireName: r'minHour')
  num? get minHour;

  @BuiltValueField(wireName: r'maxHour')
  num? get maxHour;

  @BuiltValueField(wireName: r'weight')
  num get weight;

  @BuiltValueField(wireName: r'isActive')
  bool get isActive;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  CompanionMessageResponseDto._();

  factory CompanionMessageResponseDto([void updates(CompanionMessageResponseDtoBuilder b)]) = _$CompanionMessageResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CompanionMessageResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CompanionMessageResponseDto> get serializer => _$CompanionMessageResponseDtoSerializer();
}

class _$CompanionMessageResponseDtoSerializer implements PrimitiveSerializer<CompanionMessageResponseDto> {
  @override
  final Iterable<Type> types = const [CompanionMessageResponseDto, _$CompanionMessageResponseDto];

  @override
  final String wireName = r'CompanionMessageResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CompanionMessageResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    yield r'triggerType';
    yield serializers.serialize(
      object.triggerType,
      specifiedType: const FullType(JsonObject),
    );
    yield r'mood';
    yield object.mood == null ? null : serializers.serialize(
      object.mood,
      specifiedType: const FullType.nullable(JsonObject),
    );
    yield r'companionMood';
    yield object.companionMood == null ? null : serializers.serialize(
      object.companionMood,
      specifiedType: const FullType.nullable(JsonObject),
    );
    yield r'minHour';
    yield object.minHour == null ? null : serializers.serialize(
      object.minHour,
      specifiedType: const FullType.nullable(num),
    );
    yield r'maxHour';
    yield object.maxHour == null ? null : serializers.serialize(
      object.maxHour,
      specifiedType: const FullType.nullable(num),
    );
    yield r'weight';
    yield serializers.serialize(
      object.weight,
      specifiedType: const FullType(num),
    );
    yield r'isActive';
    yield serializers.serialize(
      object.isActive,
      specifiedType: const FullType(bool),
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
    CompanionMessageResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CompanionMessageResponseDtoBuilder result,
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
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'triggerType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.triggerType = valueDes;
          break;
        case r'mood':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.mood = valueDes;
          break;
        case r'companionMood':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.companionMood = valueDes;
          break;
        case r'minHour':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.minHour = valueDes;
          break;
        case r'maxHour':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.maxHour = valueDes;
          break;
        case r'weight':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.weight = valueDes;
          break;
        case r'isActive':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isActive = valueDes;
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
  CompanionMessageResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CompanionMessageResponseDtoBuilder();
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

