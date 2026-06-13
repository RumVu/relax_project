//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_breathing_exercise_dto.g.dart';

/// CreateBreathingExerciseDto
///
/// Properties:
/// * [title] 
/// * [description] 
/// * [inhaleSeconds] 
/// * [holdSeconds] 
/// * [exhaleSeconds] 
/// * [cycles] 
/// * [duration] 
/// * [imageUrl] 
/// * [isActive] 
@BuiltValue()
abstract class CreateBreathingExerciseDto implements Built<CreateBreathingExerciseDto, CreateBreathingExerciseDtoBuilder> {
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
  bool? get isActive;

  CreateBreathingExerciseDto._();

  factory CreateBreathingExerciseDto([void updates(CreateBreathingExerciseDtoBuilder b)]) = _$CreateBreathingExerciseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateBreathingExerciseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateBreathingExerciseDto> get serializer => _$CreateBreathingExerciseDtoSerializer();
}

class _$CreateBreathingExerciseDtoSerializer implements PrimitiveSerializer<CreateBreathingExerciseDto> {
  @override
  final Iterable<Type> types = const [CreateBreathingExerciseDto, _$CreateBreathingExerciseDto];

  @override
  final String wireName = r'CreateBreathingExerciseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateBreathingExerciseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
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
    if (object.duration != null) {
      yield r'duration';
      yield serializers.serialize(
        object.duration,
        specifiedType: const FullType(num),
      );
    }
    if (object.imageUrl != null) {
      yield r'imageUrl';
      yield serializers.serialize(
        object.imageUrl,
        specifiedType: const FullType(String),
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
    CreateBreathingExerciseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateBreathingExerciseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
            specifiedType: const FullType(String),
          ) as String;
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
            specifiedType: const FullType(num),
          ) as num;
          result.duration = valueDes;
          break;
        case r'imageUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.imageUrl = valueDes;
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
  CreateBreathingExerciseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateBreathingExerciseDtoBuilder();
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

