//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:relax_api_client/src/model/user_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_response_dto.g.dart';

/// AuthResponseDto
///
/// Properties:
/// * [accessToken] 
/// * [refreshToken] 
/// * [expiresAt] 
/// * [sessionId] 
/// * [user] 
@BuiltValue()
abstract class AuthResponseDto implements Built<AuthResponseDto, AuthResponseDtoBuilder> {
  @BuiltValueField(wireName: r'accessToken')
  String get accessToken;

  @BuiltValueField(wireName: r'refreshToken')
  String? get refreshToken;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime get expiresAt;

  @BuiltValueField(wireName: r'sessionId')
  String? get sessionId;

  @BuiltValueField(wireName: r'user')
  UserResponseDto get user;

  AuthResponseDto._();

  factory AuthResponseDto([void updates(AuthResponseDtoBuilder b)]) = _$AuthResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthResponseDto> get serializer => _$AuthResponseDtoSerializer();
}

class _$AuthResponseDtoSerializer implements PrimitiveSerializer<AuthResponseDto> {
  @override
  final Iterable<Type> types = const [AuthResponseDto, _$AuthResponseDto];

  @override
  final String wireName = r'AuthResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'accessToken';
    yield serializers.serialize(
      object.accessToken,
      specifiedType: const FullType(String),
    );
    if (object.refreshToken != null) {
      yield r'refreshToken';
      yield serializers.serialize(
        object.refreshToken,
        specifiedType: const FullType(String),
      );
    }
    yield r'expiresAt';
    yield serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.sessionId != null) {
      yield r'sessionId';
      yield serializers.serialize(
        object.sessionId,
        specifiedType: const FullType(String),
      );
    }
    yield r'user';
    yield serializers.serialize(
      object.user,
      specifiedType: const FullType(UserResponseDto),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'accessToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accessToken = valueDes;
          break;
        case r'refreshToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.refreshToken = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'sessionId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sessionId = valueDes;
          break;
        case r'user':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(UserResponseDto),
          ) as UserResponseDto;
          result.user.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AuthResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthResponseDtoBuilder();
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

