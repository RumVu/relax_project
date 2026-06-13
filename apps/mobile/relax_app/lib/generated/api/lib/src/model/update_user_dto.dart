//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_user_dto.g.dart';

/// UpdateUserDto
///
/// Properties:
/// * [email] 
/// * [name] 
/// * [avatar] 
/// * [password] 
/// * [role] 
/// * [authProvider] 
/// * [emailVerified] 
/// * [isActive] 
@BuiltValue()
abstract class UpdateUserDto implements Built<UpdateUserDto, UpdateUserDtoBuilder> {
  @BuiltValueField(wireName: r'email')
  String? get email;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'avatar')
  String? get avatar;

  @BuiltValueField(wireName: r'password')
  String? get password;

  @BuiltValueField(wireName: r'role')
  JsonObject? get role;

  @BuiltValueField(wireName: r'authProvider')
  JsonObject? get authProvider;

  @BuiltValueField(wireName: r'emailVerified')
  bool? get emailVerified;

  @BuiltValueField(wireName: r'isActive')
  bool? get isActive;

  UpdateUserDto._();

  factory UpdateUserDto([void updates(UpdateUserDtoBuilder b)]) = _$UpdateUserDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateUserDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateUserDto> get serializer => _$UpdateUserDtoSerializer();
}

class _$UpdateUserDtoSerializer implements PrimitiveSerializer<UpdateUserDto> {
  @override
  final Iterable<Type> types = const [UpdateUserDto, _$UpdateUserDto];

  @override
  final String wireName = r'UpdateUserDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateUserDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.email != null) {
      yield r'email';
      yield serializers.serialize(
        object.email,
        specifiedType: const FullType(String),
      );
    }
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.avatar != null) {
      yield r'avatar';
      yield serializers.serialize(
        object.avatar,
        specifiedType: const FullType(String),
      );
    }
    if (object.password != null) {
      yield r'password';
      yield serializers.serialize(
        object.password,
        specifiedType: const FullType(String),
      );
    }
    if (object.role != null) {
      yield r'role';
      yield serializers.serialize(
        object.role,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.authProvider != null) {
      yield r'authProvider';
      yield serializers.serialize(
        object.authProvider,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.emailVerified != null) {
      yield r'emailVerified';
      yield serializers.serialize(
        object.emailVerified,
        specifiedType: const FullType(bool),
      );
    }
    if (object.isActive != null) {
      yield r'isActive';
      yield serializers.serialize(
        object.isActive,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateUserDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateUserDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'avatar':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.avatar = valueDes;
          break;
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        case r'role':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.role = valueDes;
          break;
        case r'authProvider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.authProvider = valueDes;
          break;
        case r'emailVerified':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.emailVerified = valueDes;
          break;
        case r'isActive':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isActive = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateUserDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateUserDtoBuilder();
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

