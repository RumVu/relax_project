//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:relax_api_client/src/model/user_preference_response_dto.dart';
import 'package:relax_api_client/src/model/user_profile_response_dto.dart';
import 'package:relax_api_client/src/model/user_subscription_summary_dto.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_response_dto.g.dart';

/// UserResponseDto
///
/// Properties:
/// * [id] 
/// * [email] 
/// * [name] 
/// * [avatar] 
/// * [role] 
/// * [authProvider] 
/// * [emailVerified] 
/// * [isActive] 
/// * [lastLoginAt] 
/// * [deletedAt] 
/// * [createdAt] 
/// * [updatedAt] 
/// * [profile] 
/// * [preferences] 
/// * [subscriptions] 
@BuiltValue()
abstract class UserResponseDto implements Built<UserResponseDto, UserResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'email')
  String get email;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'avatar')
  String? get avatar;

  @BuiltValueField(wireName: r'role')
  JsonObject get role;

  @BuiltValueField(wireName: r'authProvider')
  JsonObject get authProvider;

  @BuiltValueField(wireName: r'emailVerified')
  bool get emailVerified;

  @BuiltValueField(wireName: r'isActive')
  bool get isActive;

  @BuiltValueField(wireName: r'lastLoginAt')
  DateTime? get lastLoginAt;

  @BuiltValueField(wireName: r'deletedAt')
  DateTime? get deletedAt;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'profile')
  UserProfileResponseDto? get profile;

  @BuiltValueField(wireName: r'preferences')
  UserPreferenceResponseDto? get preferences;

  @BuiltValueField(wireName: r'subscriptions')
  BuiltList<UserSubscriptionSummaryDto>? get subscriptions;

  UserResponseDto._();

  factory UserResponseDto([void updates(UserResponseDtoBuilder b)]) = _$UserResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserResponseDto> get serializer => _$UserResponseDtoSerializer();
}

class _$UserResponseDtoSerializer implements PrimitiveSerializer<UserResponseDto> {
  @override
  final Iterable<Type> types = const [UserResponseDto, _$UserResponseDto];

  @override
  final String wireName = r'UserResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
    yield r'name';
    yield object.name == null ? null : serializers.serialize(
      object.name,
      specifiedType: const FullType.nullable(String),
    );
    yield r'avatar';
    yield object.avatar == null ? null : serializers.serialize(
      object.avatar,
      specifiedType: const FullType.nullable(String),
    );
    yield r'role';
    yield serializers.serialize(
      object.role,
      specifiedType: const FullType(JsonObject),
    );
    yield r'authProvider';
    yield serializers.serialize(
      object.authProvider,
      specifiedType: const FullType(JsonObject),
    );
    yield r'emailVerified';
    yield serializers.serialize(
      object.emailVerified,
      specifiedType: const FullType(bool),
    );
    yield r'isActive';
    yield serializers.serialize(
      object.isActive,
      specifiedType: const FullType(bool),
    );
    yield r'lastLoginAt';
    yield object.lastLoginAt == null ? null : serializers.serialize(
      object.lastLoginAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'deletedAt';
    yield object.deletedAt == null ? null : serializers.serialize(
      object.deletedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    yield r'updatedAt';
    yield serializers.serialize(
      object.updatedAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.profile != null) {
      yield r'profile';
      yield serializers.serialize(
        object.profile,
        specifiedType: const FullType.nullable(UserProfileResponseDto),
      );
    }
    if (object.preferences != null) {
      yield r'preferences';
      yield serializers.serialize(
        object.preferences,
        specifiedType: const FullType.nullable(UserPreferenceResponseDto),
      );
    }
    if (object.subscriptions != null) {
      yield r'subscriptions';
      yield serializers.serialize(
        object.subscriptions,
        specifiedType: const FullType(BuiltList, [FullType(UserSubscriptionSummaryDto)]),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserResponseDtoBuilder result,
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
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.name = valueDes;
          break;
        case r'avatar':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatar = valueDes;
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
        case r'lastLoginAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastLoginAt = valueDes;
          break;
        case r'deletedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.deletedAt = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'updatedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.updatedAt = valueDes;
          break;
        case r'profile':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(UserProfileResponseDto),
          ) as UserProfileResponseDto?;
          if (valueDes == null) continue;
          result.profile.replace(valueDes);
          break;
        case r'preferences':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(UserPreferenceResponseDto),
          ) as UserPreferenceResponseDto?;
          if (valueDes == null) continue;
          result.preferences.replace(valueDes);
          break;
        case r'subscriptions':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(UserSubscriptionSummaryDto)]),
          ) as BuiltList<UserSubscriptionSummaryDto>;
          result.subscriptions.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserResponseDtoBuilder();
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

