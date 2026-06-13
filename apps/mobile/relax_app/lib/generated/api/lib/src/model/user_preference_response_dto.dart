//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_preference_response_dto.g.dart';

/// UserPreferenceResponseDto
///
/// Properties:
/// * [id] 
/// * [userId] 
/// * [language] 
/// * [timezone] 
/// * [latitude] 
/// * [longitude] 
/// * [locationName] 
/// * [weatherEnabled] 
/// * [themeMode] 
/// * [themeId] 
/// * [enableCompanionBubble] 
/// * [bubbleIntervalSeconds] 
/// * [enableSound] 
/// * [enableHaptics] 
/// * [pushNotificationsEnabled] 
/// * [emailNotificationsEnabled] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class UserPreferenceResponseDto implements Built<UserPreferenceResponseDto, UserPreferenceResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'language')
  String get language;

  @BuiltValueField(wireName: r'timezone')
  String get timezone;

  @BuiltValueField(wireName: r'latitude')
  num? get latitude;

  @BuiltValueField(wireName: r'longitude')
  num? get longitude;

  @BuiltValueField(wireName: r'locationName')
  String? get locationName;

  @BuiltValueField(wireName: r'weatherEnabled')
  bool get weatherEnabled;

  @BuiltValueField(wireName: r'themeMode')
  JsonObject get themeMode;

  @BuiltValueField(wireName: r'themeId')
  String? get themeId;

  @BuiltValueField(wireName: r'enableCompanionBubble')
  bool get enableCompanionBubble;

  @BuiltValueField(wireName: r'bubbleIntervalSeconds')
  num get bubbleIntervalSeconds;

  @BuiltValueField(wireName: r'enableSound')
  bool get enableSound;

  @BuiltValueField(wireName: r'enableHaptics')
  bool get enableHaptics;

  @BuiltValueField(wireName: r'pushNotificationsEnabled')
  bool get pushNotificationsEnabled;

  @BuiltValueField(wireName: r'emailNotificationsEnabled')
  bool get emailNotificationsEnabled;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  UserPreferenceResponseDto._();

  factory UserPreferenceResponseDto([void updates(UserPreferenceResponseDtoBuilder b)]) = _$UserPreferenceResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserPreferenceResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserPreferenceResponseDto> get serializer => _$UserPreferenceResponseDtoSerializer();
}

class _$UserPreferenceResponseDtoSerializer implements PrimitiveSerializer<UserPreferenceResponseDto> {
  @override
  final Iterable<Type> types = const [UserPreferenceResponseDto, _$UserPreferenceResponseDto];

  @override
  final String wireName = r'UserPreferenceResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserPreferenceResponseDto object, {
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
    yield r'language';
    yield serializers.serialize(
      object.language,
      specifiedType: const FullType(String),
    );
    yield r'timezone';
    yield serializers.serialize(
      object.timezone,
      specifiedType: const FullType(String),
    );
    yield r'latitude';
    yield object.latitude == null ? null : serializers.serialize(
      object.latitude,
      specifiedType: const FullType.nullable(num),
    );
    yield r'longitude';
    yield object.longitude == null ? null : serializers.serialize(
      object.longitude,
      specifiedType: const FullType.nullable(num),
    );
    yield r'locationName';
    yield object.locationName == null ? null : serializers.serialize(
      object.locationName,
      specifiedType: const FullType.nullable(String),
    );
    yield r'weatherEnabled';
    yield serializers.serialize(
      object.weatherEnabled,
      specifiedType: const FullType(bool),
    );
    yield r'themeMode';
    yield serializers.serialize(
      object.themeMode,
      specifiedType: const FullType(JsonObject),
    );
    yield r'themeId';
    yield object.themeId == null ? null : serializers.serialize(
      object.themeId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'enableCompanionBubble';
    yield serializers.serialize(
      object.enableCompanionBubble,
      specifiedType: const FullType(bool),
    );
    yield r'bubbleIntervalSeconds';
    yield serializers.serialize(
      object.bubbleIntervalSeconds,
      specifiedType: const FullType(num),
    );
    yield r'enableSound';
    yield serializers.serialize(
      object.enableSound,
      specifiedType: const FullType(bool),
    );
    yield r'enableHaptics';
    yield serializers.serialize(
      object.enableHaptics,
      specifiedType: const FullType(bool),
    );
    yield r'pushNotificationsEnabled';
    yield serializers.serialize(
      object.pushNotificationsEnabled,
      specifiedType: const FullType(bool),
    );
    yield r'emailNotificationsEnabled';
    yield serializers.serialize(
      object.emailNotificationsEnabled,
      specifiedType: const FullType(bool),
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
  }

  @override
  Object serialize(
    Serializers serializers,
    UserPreferenceResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserPreferenceResponseDtoBuilder result,
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
        case r'language':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.language = valueDes;
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.timezone = valueDes;
          break;
        case r'latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.longitude = valueDes;
          break;
        case r'locationName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.locationName = valueDes;
          break;
        case r'weatherEnabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.weatherEnabled = valueDes;
          break;
        case r'themeMode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.themeMode = valueDes;
          break;
        case r'themeId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.themeId = valueDes;
          break;
        case r'enableCompanionBubble':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enableCompanionBubble = valueDes;
          break;
        case r'bubbleIntervalSeconds':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.bubbleIntervalSeconds = valueDes;
          break;
        case r'enableSound':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enableSound = valueDes;
          break;
        case r'enableHaptics':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enableHaptics = valueDes;
          break;
        case r'pushNotificationsEnabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.pushNotificationsEnabled = valueDes;
          break;
        case r'emailNotificationsEnabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.emailNotificationsEnabled = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserPreferenceResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserPreferenceResponseDtoBuilder();
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

