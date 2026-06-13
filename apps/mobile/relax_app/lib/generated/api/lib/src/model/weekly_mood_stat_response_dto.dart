//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'weekly_mood_stat_response_dto.g.dart';

/// WeeklyMoodStatResponseDto
///
/// Properties:
/// * [id] 
/// * [userId] 
/// * [weekStart] 
/// * [avgScore] 
/// * [stressReducePct] 
/// * [streakDays] 
/// * [dominantMood] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class WeeklyMoodStatResponseDto implements Built<WeeklyMoodStatResponseDto, WeeklyMoodStatResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'weekStart')
  DateTime get weekStart;

  @BuiltValueField(wireName: r'avgScore')
  num get avgScore;

  @BuiltValueField(wireName: r'stressReducePct')
  num get stressReducePct;

  @BuiltValueField(wireName: r'streakDays')
  num get streakDays;

  @BuiltValueField(wireName: r'dominantMood')
  JsonObject? get dominantMood;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  WeeklyMoodStatResponseDto._();

  factory WeeklyMoodStatResponseDto([void updates(WeeklyMoodStatResponseDtoBuilder b)]) = _$WeeklyMoodStatResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WeeklyMoodStatResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WeeklyMoodStatResponseDto> get serializer => _$WeeklyMoodStatResponseDtoSerializer();
}

class _$WeeklyMoodStatResponseDtoSerializer implements PrimitiveSerializer<WeeklyMoodStatResponseDto> {
  @override
  final Iterable<Type> types = const [WeeklyMoodStatResponseDto, _$WeeklyMoodStatResponseDto];

  @override
  final String wireName = r'WeeklyMoodStatResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WeeklyMoodStatResponseDto object, {
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
    yield r'weekStart';
    yield serializers.serialize(
      object.weekStart,
      specifiedType: const FullType(DateTime),
    );
    yield r'avgScore';
    yield serializers.serialize(
      object.avgScore,
      specifiedType: const FullType(num),
    );
    yield r'stressReducePct';
    yield serializers.serialize(
      object.stressReducePct,
      specifiedType: const FullType(num),
    );
    yield r'streakDays';
    yield serializers.serialize(
      object.streakDays,
      specifiedType: const FullType(num),
    );
    yield r'dominantMood';
    yield object.dominantMood == null ? null : serializers.serialize(
      object.dominantMood,
      specifiedType: const FullType.nullable(JsonObject),
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
    WeeklyMoodStatResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WeeklyMoodStatResponseDtoBuilder result,
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
        case r'weekStart':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.weekStart = valueDes;
          break;
        case r'avgScore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.avgScore = valueDes;
          break;
        case r'stressReducePct':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.stressReducePct = valueDes;
          break;
        case r'streakDays':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.streakDays = valueDes;
          break;
        case r'dominantMood':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.dominantMood = valueDes;
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
  WeeklyMoodStatResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WeeklyMoodStatResponseDtoBuilder();
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

