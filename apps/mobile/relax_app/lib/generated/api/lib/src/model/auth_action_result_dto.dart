//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:relax_api_client/src/model/user_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'auth_action_result_dto.g.dart';

/// AuthActionResultDto
///
/// Properties:
/// * [success] 
/// * [mode] 
/// * [revokedSessions] 
/// * [anonymized] 
/// * [devToken] 
/// * [expiresAt] 
/// * [user] 
@BuiltValue()
abstract class AuthActionResultDto implements Built<AuthActionResultDto, AuthActionResultDtoBuilder> {
  @BuiltValueField(wireName: r'success')
  bool? get success;

  @BuiltValueField(wireName: r'mode')
  String? get mode;

  @BuiltValueField(wireName: r'revokedSessions')
  bool? get revokedSessions;

  @BuiltValueField(wireName: r'anonymized')
  bool? get anonymized;

  @BuiltValueField(wireName: r'devToken')
  String? get devToken;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime? get expiresAt;

  @BuiltValueField(wireName: r'user')
  UserResponseDto? get user;

  AuthActionResultDto._();

  factory AuthActionResultDto([void updates(AuthActionResultDtoBuilder b)]) = _$AuthActionResultDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AuthActionResultDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AuthActionResultDto> get serializer => _$AuthActionResultDtoSerializer();
}

class _$AuthActionResultDtoSerializer implements PrimitiveSerializer<AuthActionResultDto> {
  @override
  final Iterable<Type> types = const [AuthActionResultDto, _$AuthActionResultDto];

  @override
  final String wireName = r'AuthActionResultDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AuthActionResultDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.success != null) {
      yield r'success';
      yield serializers.serialize(
        object.success,
        specifiedType: const FullType(bool),
      );
    }
    if (object.mode != null) {
      yield r'mode';
      yield serializers.serialize(
        object.mode,
        specifiedType: const FullType(String),
      );
    }
    if (object.revokedSessions != null) {
      yield r'revokedSessions';
      yield serializers.serialize(
        object.revokedSessions,
        specifiedType: const FullType(bool),
      );
    }
    if (object.anonymized != null) {
      yield r'anonymized';
      yield serializers.serialize(
        object.anonymized,
        specifiedType: const FullType(bool),
      );
    }
    if (object.devToken != null) {
      yield r'devToken';
      yield serializers.serialize(
        object.devToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.expiresAt != null) {
      yield r'expiresAt';
      yield serializers.serialize(
        object.expiresAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.user != null) {
      yield r'user';
      yield serializers.serialize(
        object.user,
        specifiedType: const FullType(UserResponseDto),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AuthActionResultDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AuthActionResultDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'success':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.success = valueDes;
          break;
        case r'mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mode = valueDes;
          break;
        case r'revokedSessions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.revokedSessions = valueDes;
          break;
        case r'anonymized':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.anonymized = valueDes;
          break;
        case r'devToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.devToken = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
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
  AuthActionResultDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AuthActionResultDtoBuilder();
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

