//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_meditation_session_dto.g.dart';

/// CreateMeditationSessionDto
///
/// Properties:
/// * [guideId] 
/// * [duration] 
/// * [startedAt] 
/// * [endedAt] 
/// * [focusArea] 
/// * [mood] 
/// * [quality] 
/// * [notes] 
@BuiltValue()
abstract class CreateMeditationSessionDto implements Built<CreateMeditationSessionDto, CreateMeditationSessionDtoBuilder> {
  @BuiltValueField(wireName: r'guideId')
  String? get guideId;

  @BuiltValueField(wireName: r'duration')
  num get duration;

  @BuiltValueField(wireName: r'startedAt')
  String get startedAt;

  @BuiltValueField(wireName: r'endedAt')
  String? get endedAt;

  @BuiltValueField(wireName: r'focusArea')
  String? get focusArea;

  @BuiltValueField(wireName: r'mood')
  JsonObject? get mood;

  @BuiltValueField(wireName: r'quality')
  num? get quality;

  @BuiltValueField(wireName: r'notes')
  String? get notes;

  CreateMeditationSessionDto._();

  factory CreateMeditationSessionDto([void updates(CreateMeditationSessionDtoBuilder b)]) = _$CreateMeditationSessionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateMeditationSessionDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateMeditationSessionDto> get serializer => _$CreateMeditationSessionDtoSerializer();
}

class _$CreateMeditationSessionDtoSerializer implements PrimitiveSerializer<CreateMeditationSessionDto> {
  @override
  final Iterable<Type> types = const [CreateMeditationSessionDto, _$CreateMeditationSessionDto];

  @override
  final String wireName = r'CreateMeditationSessionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateMeditationSessionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.guideId != null) {
      yield r'guideId';
      yield serializers.serialize(
        object.guideId,
        specifiedType: const FullType(String),
      );
    }
    yield r'duration';
    yield serializers.serialize(
      object.duration,
      specifiedType: const FullType(num),
    );
    yield r'startedAt';
    yield serializers.serialize(
      object.startedAt,
      specifiedType: const FullType(String),
    );
    if (object.endedAt != null) {
      yield r'endedAt';
      yield serializers.serialize(
        object.endedAt,
        specifiedType: const FullType(String),
      );
    }
    if (object.focusArea != null) {
      yield r'focusArea';
      yield serializers.serialize(
        object.focusArea,
        specifiedType: const FullType(String),
      );
    }
    if (object.mood != null) {
      yield r'mood';
      yield serializers.serialize(
        object.mood,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.quality != null) {
      yield r'quality';
      yield serializers.serialize(
        object.quality,
        specifiedType: const FullType(num),
      );
    }
    if (object.notes != null) {
      yield r'notes';
      yield serializers.serialize(
        object.notes,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateMeditationSessionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateMeditationSessionDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'guideId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.guideId = valueDes;
          break;
        case r'duration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.duration = valueDes;
          break;
        case r'startedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.startedAt = valueDes;
          break;
        case r'endedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.endedAt = valueDes;
          break;
        case r'focusArea':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.focusArea = valueDes;
          break;
        case r'mood':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.mood = valueDes;
          break;
        case r'quality':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.quality = valueDes;
          break;
        case r'notes':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.notes = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateMeditationSessionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateMeditationSessionDtoBuilder();
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

