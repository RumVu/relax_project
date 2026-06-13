//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'google_login_dto.g.dart';

/// GoogleLoginDto
///
/// Properties:
/// * [idToken] - Legacy GIS ID token. Kept for backwards compatibility.
/// * [accessToken] - Legacy OAuth access token. Kept for backwards compatibility.
/// * [authorizationCode] - OAuth authorization code returned to /auth/google/callback. Backend exchanges this using GOOGLE_CLIENT_SECRET.
/// * [redirectUri] 
@BuiltValue()
abstract class GoogleLoginDto implements Built<GoogleLoginDto, GoogleLoginDtoBuilder> {
  /// Legacy GIS ID token. Kept for backwards compatibility.
  @BuiltValueField(wireName: r'idToken')
  String? get idToken;

  /// Legacy OAuth access token. Kept for backwards compatibility.
  @BuiltValueField(wireName: r'accessToken')
  String? get accessToken;

  /// OAuth authorization code returned to /auth/google/callback. Backend exchanges this using GOOGLE_CLIENT_SECRET.
  @BuiltValueField(wireName: r'authorizationCode')
  String? get authorizationCode;

  @BuiltValueField(wireName: r'redirectUri')
  String? get redirectUri;

  GoogleLoginDto._();

  factory GoogleLoginDto([void updates(GoogleLoginDtoBuilder b)]) = _$GoogleLoginDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(GoogleLoginDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<GoogleLoginDto> get serializer => _$GoogleLoginDtoSerializer();
}

class _$GoogleLoginDtoSerializer implements PrimitiveSerializer<GoogleLoginDto> {
  @override
  final Iterable<Type> types = const [GoogleLoginDto, _$GoogleLoginDto];

  @override
  final String wireName = r'GoogleLoginDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    GoogleLoginDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.idToken != null) {
      yield r'idToken';
      yield serializers.serialize(
        object.idToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.accessToken != null) {
      yield r'accessToken';
      yield serializers.serialize(
        object.accessToken,
        specifiedType: const FullType(String),
      );
    }
    if (object.authorizationCode != null) {
      yield r'authorizationCode';
      yield serializers.serialize(
        object.authorizationCode,
        specifiedType: const FullType(String),
      );
    }
    if (object.redirectUri != null) {
      yield r'redirectUri';
      yield serializers.serialize(
        object.redirectUri,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    GoogleLoginDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required GoogleLoginDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'idToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.idToken = valueDes;
          break;
        case r'accessToken':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accessToken = valueDes;
          break;
        case r'authorizationCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.authorizationCode = valueDes;
          break;
        case r'redirectUri':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.redirectUri = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  GoogleLoginDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = GoogleLoginDtoBuilder();
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

