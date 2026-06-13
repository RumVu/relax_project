//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_sleep_session_dto.g.dart';

/// CreateSleepSessionDto
///
/// Properties:
/// * [startedAt] 
/// * [endedAt] 
/// * [quality] 
/// * [note] 
@BuiltValue()
abstract class CreateSleepSessionDto implements Built<CreateSleepSessionDto, CreateSleepSessionDtoBuilder> {
  @BuiltValueField(wireName: r'startedAt')
  String get startedAt;

  @BuiltValueField(wireName: r'endedAt')
  String? get endedAt;

  @BuiltValueField(wireName: r'quality')
  num? get quality;

  @BuiltValueField(wireName: r'note')
  String? get note;

  CreateSleepSessionDto._();

  factory CreateSleepSessionDto([void updates(CreateSleepSessionDtoBuilder b)]) = _$CreateSleepSessionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateSleepSessionDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateSleepSessionDto> get serializer => _$CreateSleepSessionDtoSerializer();
}

class _$CreateSleepSessionDtoSerializer implements PrimitiveSerializer<CreateSleepSessionDto> {
  @override
  final Iterable<Type> types = const [CreateSleepSessionDto, _$CreateSleepSessionDto];

  @override
  final String wireName = r'CreateSleepSessionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateSleepSessionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
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
    if (object.quality != null) {
      yield r'quality';
      yield serializers.serialize(
        object.quality,
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
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateSleepSessionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateSleepSessionDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
        case r'quality':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.quality = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateSleepSessionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateSleepSessionDtoBuilder();
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

