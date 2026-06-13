//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_companion_interaction_dto.g.dart';

/// CreateCompanionInteractionDto
///
/// Properties:
/// * [type] 
/// * [metadata] 
@BuiltValue()
abstract class CreateCompanionInteractionDto implements Built<CreateCompanionInteractionDto, CreateCompanionInteractionDtoBuilder> {
  @BuiltValueField(wireName: r'type')
  String get type;

  @BuiltValueField(wireName: r'metadata')
  JsonObject? get metadata;

  CreateCompanionInteractionDto._();

  factory CreateCompanionInteractionDto([void updates(CreateCompanionInteractionDtoBuilder b)]) = _$CreateCompanionInteractionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateCompanionInteractionDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateCompanionInteractionDto> get serializer => _$CreateCompanionInteractionDtoSerializer();
}

class _$CreateCompanionInteractionDtoSerializer implements PrimitiveSerializer<CreateCompanionInteractionDto> {
  @override
  final Iterable<Type> types = const [CreateCompanionInteractionDto, _$CreateCompanionInteractionDto];

  @override
  final String wireName = r'CreateCompanionInteractionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateCompanionInteractionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(String),
    );
    if (object.metadata != null) {
      yield r'metadata';
      yield serializers.serialize(
        object.metadata,
        specifiedType: const FullType(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateCompanionInteractionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateCompanionInteractionDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.type = valueDes;
          break;
        case r'metadata':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.metadata = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateCompanionInteractionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateCompanionInteractionDtoBuilder();
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

