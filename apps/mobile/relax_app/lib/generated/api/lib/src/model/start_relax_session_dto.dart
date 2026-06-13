//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'start_relax_session_dto.g.dart';

/// StartRelaxSessionDto
///
/// Properties:
/// * [activityType] 
/// * [resourceId] 
/// * [title] 
/// * [moodBefore] 
@BuiltValue()
abstract class StartRelaxSessionDto implements Built<StartRelaxSessionDto, StartRelaxSessionDtoBuilder> {
  @BuiltValueField(wireName: r'activityType')
  JsonObject get activityType;

  @BuiltValueField(wireName: r'resourceId')
  String? get resourceId;

  @BuiltValueField(wireName: r'title')
  String? get title;

  @BuiltValueField(wireName: r'moodBefore')
  JsonObject? get moodBefore;

  StartRelaxSessionDto._();

  factory StartRelaxSessionDto([void updates(StartRelaxSessionDtoBuilder b)]) = _$StartRelaxSessionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StartRelaxSessionDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StartRelaxSessionDto> get serializer => _$StartRelaxSessionDtoSerializer();
}

class _$StartRelaxSessionDtoSerializer implements PrimitiveSerializer<StartRelaxSessionDto> {
  @override
  final Iterable<Type> types = const [StartRelaxSessionDto, _$StartRelaxSessionDto];

  @override
  final String wireName = r'StartRelaxSessionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StartRelaxSessionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'activityType';
    yield serializers.serialize(
      object.activityType,
      specifiedType: const FullType(JsonObject),
    );
    if (object.resourceId != null) {
      yield r'resourceId';
      yield serializers.serialize(
        object.resourceId,
        specifiedType: const FullType(String),
      );
    }
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    if (object.moodBefore != null) {
      yield r'moodBefore';
      yield serializers.serialize(
        object.moodBefore,
        specifiedType: const FullType(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    StartRelaxSessionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StartRelaxSessionDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'activityType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.activityType = valueDes;
          break;
        case r'resourceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.resourceId = valueDes;
          break;
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'moodBefore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.moodBefore = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StartRelaxSessionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StartRelaxSessionDtoBuilder();
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

