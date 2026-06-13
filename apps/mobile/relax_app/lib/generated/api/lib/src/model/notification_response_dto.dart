//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_response_dto.g.dart';

/// NotificationResponseDto
///
/// Properties:
/// * [id] 
/// * [userId] 
/// * [title] 
/// * [message] 
/// * [type] 
/// * [relatedEntity] 
/// * [relatedId] 
/// * [isRead] 
/// * [readAt] 
/// * [createdAt] 
@BuiltValue()
abstract class NotificationResponseDto implements Built<NotificationResponseDto, NotificationResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'message')
  String get message;

  @BuiltValueField(wireName: r'type')
  JsonObject get type;

  @BuiltValueField(wireName: r'relatedEntity')
  String? get relatedEntity;

  @BuiltValueField(wireName: r'relatedId')
  String? get relatedId;

  @BuiltValueField(wireName: r'isRead')
  bool get isRead;

  @BuiltValueField(wireName: r'readAt')
  DateTime? get readAt;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  NotificationResponseDto._();

  factory NotificationResponseDto([void updates(NotificationResponseDtoBuilder b)]) = _$NotificationResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationResponseDto> get serializer => _$NotificationResponseDtoSerializer();
}

class _$NotificationResponseDtoSerializer implements PrimitiveSerializer<NotificationResponseDto> {
  @override
  final Iterable<Type> types = const [NotificationResponseDto, _$NotificationResponseDto];

  @override
  final String wireName = r'NotificationResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationResponseDto object, {
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
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(JsonObject),
    );
    yield r'relatedEntity';
    yield object.relatedEntity == null ? null : serializers.serialize(
      object.relatedEntity,
      specifiedType: const FullType.nullable(String),
    );
    yield r'relatedId';
    yield object.relatedId == null ? null : serializers.serialize(
      object.relatedId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'isRead';
    yield serializers.serialize(
      object.isRead,
      specifiedType: const FullType(bool),
    );
    yield r'readAt';
    yield object.readAt == null ? null : serializers.serialize(
      object.readAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    NotificationResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationResponseDtoBuilder result,
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
        case r'relatedEntity':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.relatedEntity = valueDes;
          break;
        case r'relatedId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.relatedId = valueDes;
          break;
        case r'isRead':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isRead = valueDes;
          break;
        case r'readAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.readAt = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  NotificationResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationResponseDtoBuilder();
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

