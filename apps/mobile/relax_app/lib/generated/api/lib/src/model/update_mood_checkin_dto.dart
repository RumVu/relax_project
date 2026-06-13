//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_mood_checkin_dto.g.dart';

/// UpdateMoodCheckinDto
///
/// Properties:
/// * [mood] 
/// * [intensity] 
/// * [note] 
/// * [tags] 
/// * [trigger] 
@BuiltValue()
abstract class UpdateMoodCheckinDto implements Built<UpdateMoodCheckinDto, UpdateMoodCheckinDtoBuilder> {
  @BuiltValueField(wireName: r'mood')
  JsonObject? get mood;

  @BuiltValueField(wireName: r'intensity')
  num? get intensity;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'tags')
  BuiltList<String>? get tags;

  @BuiltValueField(wireName: r'trigger')
  JsonObject? get trigger;

  UpdateMoodCheckinDto._();

  factory UpdateMoodCheckinDto([void updates(UpdateMoodCheckinDtoBuilder b)]) = _$UpdateMoodCheckinDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateMoodCheckinDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateMoodCheckinDto> get serializer => _$UpdateMoodCheckinDtoSerializer();
}

class _$UpdateMoodCheckinDtoSerializer implements PrimitiveSerializer<UpdateMoodCheckinDto> {
  @override
  final Iterable<Type> types = const [UpdateMoodCheckinDto, _$UpdateMoodCheckinDto];

  @override
  final String wireName = r'UpdateMoodCheckinDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateMoodCheckinDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.mood != null) {
      yield r'mood';
      yield serializers.serialize(
        object.mood,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.intensity != null) {
      yield r'intensity';
      yield serializers.serialize(
        object.intensity,
        specifiedType: const FullType(num),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
    if (object.tags != null) {
      yield r'tags';
      yield serializers.serialize(
        object.tags,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.trigger != null) {
      yield r'trigger';
      yield serializers.serialize(
        object.trigger,
        specifiedType: const FullType(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateMoodCheckinDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateMoodCheckinDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mood':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.mood = valueDes;
          break;
        case r'intensity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.intensity = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        case r'tags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.tags.replace(valueDes);
          break;
        case r'trigger':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.trigger = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateMoodCheckinDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateMoodCheckinDtoBuilder();
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

