//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'breathing_exercise_response_dto.g.dart';

/// BreathingExerciseResponseDto
///
/// Properties:
/// * [id] 
/// * [title] 
/// * [description] 
/// * [inhaleSeconds] 
/// * [holdSeconds] 
/// * [exhaleSeconds] 
/// * [cycles] 
/// * [duration] 
/// * [imageUrl] 
/// * [isActive] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class BreathingExerciseResponseDto implements Built<BreathingExerciseResponseDto, BreathingExerciseResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'inhaleSeconds')
  num get inhaleSeconds;

  @BuiltValueField(wireName: r'holdSeconds')
  num get holdSeconds;

  @BuiltValueField(wireName: r'exhaleSeconds')
  num get exhaleSeconds;

  @BuiltValueField(wireName: r'cycles')
  num get cycles;

  @BuiltValueField(wireName: r'duration')
  num? get duration;

  @BuiltValueField(wireName: r'imageUrl')
  String? get imageUrl;

  @BuiltValueField(wireName: r'isActive')
  bool get isActive;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  BreathingExerciseResponseDto._();

  factory BreathingExerciseResponseDto([void updates(BreathingExerciseResponseDtoBuilder b)]) = _$BreathingExerciseResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BreathingExerciseResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BreathingExerciseResponseDto> get serializer => _$BreathingExerciseResponseDtoSerializer();
}

class _$BreathingExerciseResponseDtoSerializer implements PrimitiveSerializer<BreathingExerciseResponseDto> {
  @override
  final Iterable<Type> types = const [BreathingExerciseResponseDto, _$BreathingExerciseResponseDto];

  @override
  final String wireName = r'BreathingExerciseResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BreathingExerciseResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'description';
    yield object.description == null ? null : serializers.serialize(
      object.description,
      specifiedType: const FullType.nullable(String),
    );
    yield r'inhaleSeconds';
    yield serializers.serialize(
      object.inhaleSeconds,
      specifiedType: const FullType(num),
    );
    yield r'holdSeconds';
    yield serializers.serialize(
      object.holdSeconds,
      specifiedType: const FullType(num),
    );
    yield r'exhaleSeconds';
    yield serializers.serialize(
      object.exhaleSeconds,
      specifiedType: const FullType(num),
    );
    yield r'cycles';
    yield serializers.serialize(
      object.cycles,
      specifiedType: const FullType(num),
    );
    yield r'duration';
    yield object.duration == null ? null : serializers.serialize(
      object.duration,
      specifiedType: const FullType.nullable(num),
    );
    yield r'imageUrl';
    yield object.imageUrl == null ? null : serializers.serialize(
      object.imageUrl,
      specifiedType: const FullType.nullable(String),
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
    BreathingExerciseResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BreathingExerciseResponseDtoBuilder result,
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
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'inhaleSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.inhaleSeconds = valueDes;
          break;
        case r'holdSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.holdSeconds = valueDes;
          break;
        case r'exhaleSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.exhaleSeconds = valueDes;
          break;
        case r'cycles':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.cycles = valueDes;
          break;
        case r'duration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.duration = valueDes;
          break;
        case r'imageUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.imageUrl = valueDes;
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
  BreathingExerciseResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BreathingExerciseResponseDtoBuilder();
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

