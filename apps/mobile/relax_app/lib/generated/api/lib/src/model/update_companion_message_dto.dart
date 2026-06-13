//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_companion_message_dto.g.dart';

/// UpdateCompanionMessageDto
///
/// Properties:
/// * [content] 
/// * [triggerType] 
/// * [mood] 
/// * [companionMood] 
/// * [minHour] 
/// * [maxHour] 
/// * [weight] 
/// * [isActive] 
@BuiltValue()
abstract class UpdateCompanionMessageDto implements Built<UpdateCompanionMessageDto, UpdateCompanionMessageDtoBuilder> {
  @BuiltValueField(wireName: r'content')
  String? get content;

  @BuiltValueField(wireName: r'triggerType')
  JsonObject? get triggerType;

  @BuiltValueField(wireName: r'mood')
  JsonObject? get mood;

  @BuiltValueField(wireName: r'companionMood')
  JsonObject? get companionMood;

  @BuiltValueField(wireName: r'minHour')
  num? get minHour;

  @BuiltValueField(wireName: r'maxHour')
  num? get maxHour;

  @BuiltValueField(wireName: r'weight')
  num? get weight;

  @BuiltValueField(wireName: r'isActive')
  bool? get isActive;

  UpdateCompanionMessageDto._();

  factory UpdateCompanionMessageDto([void updates(UpdateCompanionMessageDtoBuilder b)]) = _$UpdateCompanionMessageDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateCompanionMessageDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateCompanionMessageDto> get serializer => _$UpdateCompanionMessageDtoSerializer();
}

class _$UpdateCompanionMessageDtoSerializer implements PrimitiveSerializer<UpdateCompanionMessageDto> {
  @override
  final Iterable<Type> types = const [UpdateCompanionMessageDto, _$UpdateCompanionMessageDto];

  @override
  final String wireName = r'UpdateCompanionMessageDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateCompanionMessageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.content != null) {
      yield r'content';
      yield serializers.serialize(
        object.content,
        specifiedType: const FullType(String),
      );
    }
    if (object.triggerType != null) {
      yield r'triggerType';
      yield serializers.serialize(
        object.triggerType,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.mood != null) {
      yield r'mood';
      yield serializers.serialize(
        object.mood,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.companionMood != null) {
      yield r'companionMood';
      yield serializers.serialize(
        object.companionMood,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.minHour != null) {
      yield r'minHour';
      yield serializers.serialize(
        object.minHour,
        specifiedType: const FullType(num),
      );
    }
    if (object.maxHour != null) {
      yield r'maxHour';
      yield serializers.serialize(
        object.maxHour,
        specifiedType: const FullType(num),
      );
    }
    if (object.weight != null) {
      yield r'weight';
      yield serializers.serialize(
        object.weight,
        specifiedType: const FullType(num),
      );
    }
    if (object.isActive != null) {
      yield r'isActive';
      yield serializers.serialize(
        object.isActive,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateCompanionMessageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateCompanionMessageDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.mood = valueDes;
          break;
        case r'companionMood':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.companionMood = valueDes;
          break;
        case r'minHour':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.minHour = valueDes;
          break;
        case r'maxHour':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateCompanionMessageDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateCompanionMessageDtoBuilder();
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

