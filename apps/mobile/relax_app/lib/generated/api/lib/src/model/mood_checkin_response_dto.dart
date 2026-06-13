//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mood_checkin_response_dto.g.dart';

/// MoodCheckinResponseDto
///
/// Properties:
/// * [id] 
/// * [userId] 
/// * [mood] 
/// * [intensity] 
/// * [rawScore] 
/// * [finalScore] 
/// * [scoredAt] 
/// * [note] 
/// * [tags] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class MoodCheckinResponseDto implements Built<MoodCheckinResponseDto, MoodCheckinResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'mood')
  JsonObject get mood;

  @BuiltValueField(wireName: r'intensity')
  num? get intensity;

  @BuiltValueField(wireName: r'rawScore')
  num? get rawScore;

  @BuiltValueField(wireName: r'finalScore')
  num? get finalScore;

  @BuiltValueField(wireName: r'scoredAt')
  DateTime? get scoredAt;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'tags')
  BuiltList<String> get tags;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  MoodCheckinResponseDto._();

  factory MoodCheckinResponseDto([void updates(MoodCheckinResponseDtoBuilder b)]) = _$MoodCheckinResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MoodCheckinResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MoodCheckinResponseDto> get serializer => _$MoodCheckinResponseDtoSerializer();
}

class _$MoodCheckinResponseDtoSerializer implements PrimitiveSerializer<MoodCheckinResponseDto> {
  @override
  final Iterable<Type> types = const [MoodCheckinResponseDto, _$MoodCheckinResponseDto];

  @override
  final String wireName = r'MoodCheckinResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MoodCheckinResponseDto object, {
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
    yield r'mood';
    yield serializers.serialize(
      object.mood,
      specifiedType: const FullType(JsonObject),
    );
    yield r'intensity';
    yield object.intensity == null ? null : serializers.serialize(
      object.intensity,
      specifiedType: const FullType.nullable(num),
    );
    yield r'rawScore';
    yield object.rawScore == null ? null : serializers.serialize(
      object.rawScore,
      specifiedType: const FullType.nullable(num),
    );
    yield r'finalScore';
    yield object.finalScore == null ? null : serializers.serialize(
      object.finalScore,
      specifiedType: const FullType.nullable(num),
    );
    yield r'scoredAt';
    yield object.scoredAt == null ? null : serializers.serialize(
      object.scoredAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'note';
    yield object.note == null ? null : serializers.serialize(
      object.note,
      specifiedType: const FullType.nullable(String),
    );
    yield r'tags';
    yield serializers.serialize(
      object.tags,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
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
    MoodCheckinResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MoodCheckinResponseDtoBuilder result,
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
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.intensity = valueDes;
          break;
        case r'rawScore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.rawScore = valueDes;
          break;
        case r'finalScore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.finalScore = valueDes;
          break;
        case r'scoredAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.scoredAt = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.note = valueDes;
          break;
        case r'tags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.tags.replace(valueDes);
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
  MoodCheckinResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MoodCheckinResponseDtoBuilder();
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

