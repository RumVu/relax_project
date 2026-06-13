//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_notification_dto.g.dart';

/// CreateNotificationDto
///
/// Properties:
/// * [title] 
/// * [message] 
/// * [type] 
@BuiltValue()
abstract class CreateNotificationDto implements Built<CreateNotificationDto, CreateNotificationDtoBuilder> {
  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueField(wireName: r'type')
  JsonObject? get type;

  CreateNotificationDto._();

  factory CreateNotificationDto([void updates(CreateNotificationDtoBuilder b)]) = _$CreateNotificationDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateNotificationDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateNotificationDto> get serializer => _$CreateNotificationDtoSerializer();
}

class _$CreateNotificationDtoSerializer implements PrimitiveSerializer<CreateNotificationDto> {
  @override
  final Iterable<Type> types = const [CreateNotificationDto, _$CreateNotificationDto];

  @override
  final String wireName = r'CreateNotificationDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateNotificationDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateNotificationDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateNotificationDtoBuilder result,
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
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.type = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateNotificationDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateNotificationDtoBuilder();
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

