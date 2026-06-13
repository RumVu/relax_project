//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'run_weekly_mood_stats_job_dto.g.dart';

/// RunWeeklyMoodStatsJobDto
///
/// Properties:
/// * [userId] 
/// * [from] 
/// * [to] 
/// * [timezone] 
/// * [limit] 
@BuiltValue()
abstract class RunWeeklyMoodStatsJobDto implements Built<RunWeeklyMoodStatsJobDto, RunWeeklyMoodStatsJobDtoBuilder> {
  @BuiltValueField(wireName: r'userId')
  String? get userId;

  @BuiltValueField(wireName: r'from')
  DateTime? get from;

  @BuiltValueField(wireName: r'to')
  DateTime? get to;

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'limit')
  num? get limit;

  RunWeeklyMoodStatsJobDto._();

  factory RunWeeklyMoodStatsJobDto([void updates(RunWeeklyMoodStatsJobDtoBuilder b)]) = _$RunWeeklyMoodStatsJobDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RunWeeklyMoodStatsJobDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RunWeeklyMoodStatsJobDto> get serializer => _$RunWeeklyMoodStatsJobDtoSerializer();
}

class _$RunWeeklyMoodStatsJobDtoSerializer implements PrimitiveSerializer<RunWeeklyMoodStatsJobDto> {
  @override
  final Iterable<Type> types = const [RunWeeklyMoodStatsJobDto, _$RunWeeklyMoodStatsJobDto];

  @override
  final String wireName = r'RunWeeklyMoodStatsJobDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RunWeeklyMoodStatsJobDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.userId != null) {
      yield r'userId';
      yield serializers.serialize(
        object.userId,
        specifiedType: const FullType(String),
      );
    }
    if (object.from != null) {
      yield r'from';
      yield serializers.serialize(
        object.from,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.to != null) {
      yield r'to';
      yield serializers.serialize(
        object.to,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.timezone != null) {
      yield r'timezone';
      yield serializers.serialize(
        object.timezone,
        specifiedType: const FullType(String),
      );
    }
    if (object.limit != null) {
      yield r'limit';
      yield serializers.serialize(
        object.limit,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RunWeeklyMoodStatsJobDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RunWeeklyMoodStatsJobDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.userId = valueDes;
          break;
        case r'from':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.from = valueDes;
          break;
        case r'to':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.to = valueDes;
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.timezone = valueDes;
          break;
        case r'limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.limit = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RunWeeklyMoodStatsJobDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RunWeeklyMoodStatsJobDtoBuilder();
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

