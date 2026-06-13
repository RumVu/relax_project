//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'relax_session_response_dto.g.dart';

/// RelaxSessionResponseDto
///
/// Properties:
/// * [id] 
/// * [userId] 
/// * [activityType] 
/// * [status] 
/// * [resourceId] 
/// * [title] 
/// * [startedAt] 
/// * [endedAt] 
/// * [duration] 
/// * [moodBefore] 
/// * [moodAfter] 
/// * [reliefLevel] 
/// * [stressReliefPercent] 
/// * [note] 
/// * [nextActionAccepted] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class RelaxSessionResponseDto implements Built<RelaxSessionResponseDto, RelaxSessionResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'activityType')
  JsonObject get activityType;

  @BuiltValueField(wireName: r'status')
  JsonObject get status;

  @BuiltValueField(wireName: r'resourceId')
  String? get resourceId;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'startedAt')
  DateTime get startedAt;

  @BuiltValueField(wireName: r'endedAt')
  DateTime? get endedAt;

  @BuiltValueField(wireName: r'duration')
  num? get duration;

  @BuiltValueField(wireName: r'moodBefore')
  JsonObject? get moodBefore;

  @BuiltValueField(wireName: r'moodAfter')
  JsonObject? get moodAfter;

  @BuiltValueField(wireName: r'reliefLevel')
  num? get reliefLevel;

  @BuiltValueField(wireName: r'stressReliefPercent')
  num? get stressReliefPercent;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'nextActionAccepted')
  String? get nextActionAccepted;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  RelaxSessionResponseDto._();

  factory RelaxSessionResponseDto([void updates(RelaxSessionResponseDtoBuilder b)]) = _$RelaxSessionResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RelaxSessionResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RelaxSessionResponseDto> get serializer => _$RelaxSessionResponseDtoSerializer();
}

class _$RelaxSessionResponseDtoSerializer implements PrimitiveSerializer<RelaxSessionResponseDto> {
  @override
  final Iterable<Type> types = const [RelaxSessionResponseDto, _$RelaxSessionResponseDto];

  @override
  final String wireName = r'RelaxSessionResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RelaxSessionResponseDto object, {
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
    yield r'activityType';
    yield serializers.serialize(
      object.activityType,
      specifiedType: const FullType(JsonObject),
    );
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(JsonObject),
    );
    yield r'resourceId';
    yield object.resourceId == null ? null : serializers.serialize(
      object.resourceId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'startedAt';
    yield serializers.serialize(
      object.startedAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'endedAt';
    yield object.endedAt == null ? null : serializers.serialize(
      object.endedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'duration';
    yield object.duration == null ? null : serializers.serialize(
      object.duration,
      specifiedType: const FullType.nullable(num),
    );
    yield r'moodBefore';
    yield object.moodBefore == null ? null : serializers.serialize(
      object.moodBefore,
      specifiedType: const FullType.nullable(JsonObject),
    );
    yield r'moodAfter';
    yield object.moodAfter == null ? null : serializers.serialize(
      object.moodAfter,
      specifiedType: const FullType.nullable(JsonObject),
    );
    yield r'reliefLevel';
    yield object.reliefLevel == null ? null : serializers.serialize(
      object.reliefLevel,
      specifiedType: const FullType.nullable(num),
    );
    yield r'stressReliefPercent';
    yield object.stressReliefPercent == null ? null : serializers.serialize(
      object.stressReliefPercent,
      specifiedType: const FullType.nullable(num),
    );
    yield r'note';
    yield object.note == null ? null : serializers.serialize(
      object.note,
      specifiedType: const FullType.nullable(String),
    );
    yield r'nextActionAccepted';
    yield object.nextActionAccepted == null ? null : serializers.serialize(
      object.nextActionAccepted,
      specifiedType: const FullType.nullable(String),
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
    RelaxSessionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RelaxSessionResponseDtoBuilder result,
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
        case r'activityType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.activityType = valueDes;
          break;
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.status = valueDes;
          break;
        case r'resourceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.resourceId = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'startedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.startedAt = valueDes;
          break;
        case r'endedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.endedAt = valueDes;
          break;
        case r'duration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.duration = valueDes;
          break;
        case r'moodBefore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.moodBefore = valueDes;
          break;
        case r'moodAfter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.moodAfter = valueDes;
          break;
        case r'reliefLevel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.reliefLevel = valueDes;
          break;
        case r'stressReliefPercent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.stressReliefPercent = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'nextActionAccepted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.nextActionAccepted = valueDes;
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
  RelaxSessionResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RelaxSessionResponseDtoBuilder();
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

