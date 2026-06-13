//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'recalculate_weekly_mood_stats_dto.g.dart';

/// RecalculateWeeklyMoodStatsDto
///
/// Properties:
/// * [from] 
/// * [to] 
/// * [timezone] 
@BuiltValue()
abstract class RecalculateWeeklyMoodStatsDto implements Built<RecalculateWeeklyMoodStatsDto, RecalculateWeeklyMoodStatsDtoBuilder> {
  @BuiltValueField(wireName: r'from')
  DateTime? get from;

  @BuiltValueField(wireName: r'to')
  DateTime? get to;

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  RecalculateWeeklyMoodStatsDto._();

  factory RecalculateWeeklyMoodStatsDto([void updates(RecalculateWeeklyMoodStatsDtoBuilder b)]) = _$RecalculateWeeklyMoodStatsDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RecalculateWeeklyMoodStatsDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RecalculateWeeklyMoodStatsDto> get serializer => _$RecalculateWeeklyMoodStatsDtoSerializer();
}

class _$RecalculateWeeklyMoodStatsDtoSerializer implements PrimitiveSerializer<RecalculateWeeklyMoodStatsDto> {
  @override
  final Iterable<Type> types = const [RecalculateWeeklyMoodStatsDto, _$RecalculateWeeklyMoodStatsDto];

  @override
  final String wireName = r'RecalculateWeeklyMoodStatsDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RecalculateWeeklyMoodStatsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
  }

  @override
  Object serialize(
    Serializers serializers,
    RecalculateWeeklyMoodStatsDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RecalculateWeeklyMoodStatsDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RecalculateWeeklyMoodStatsDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RecalculateWeeklyMoodStatsDtoBuilder();
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

