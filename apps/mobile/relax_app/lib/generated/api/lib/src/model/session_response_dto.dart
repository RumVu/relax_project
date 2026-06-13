//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'session_response_dto.g.dart';

/// SessionResponseDto
///
/// Properties:
/// * [id] 
/// * [userId] 
/// * [userAgent] 
/// * [ipAddress] 
/// * [expiresAt] 
/// * [createdAt] 
@BuiltValue()
abstract class SessionResponseDto implements Built<SessionResponseDto, SessionResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'userAgent')
  String? get userAgent;

  @BuiltValueField(wireName: r'ipAddress')
  String? get ipAddress;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  SessionResponseDto._();

  factory SessionResponseDto([void updates(SessionResponseDtoBuilder b)]) = _$SessionResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SessionResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SessionResponseDto> get serializer => _$SessionResponseDtoSerializer();
}

class _$SessionResponseDtoSerializer implements PrimitiveSerializer<SessionResponseDto> {
  @override
  final Iterable<Type> types = const [SessionResponseDto, _$SessionResponseDto];

  @override
  final String wireName = r'SessionResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SessionResponseDto object, {
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
    yield r'userAgent';
    yield object.userAgent == null ? null : serializers.serialize(
      object.userAgent,
      specifiedType: const FullType.nullable(String),
    );
    yield r'ipAddress';
    yield object.ipAddress == null ? null : serializers.serialize(
      object.ipAddress,
      specifiedType: const FullType.nullable(String),
    );
    yield r'expiresAt';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
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
    SessionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SessionResponseDtoBuilder result,
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
        case r'userAgent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.userAgent = valueDes;
          break;
        case r'ipAddress':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.ipAddress = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
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
  SessionResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SessionResponseDtoBuilder();
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

