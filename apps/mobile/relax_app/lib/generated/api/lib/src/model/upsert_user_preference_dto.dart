//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'upsert_user_preference_dto.g.dart';

/// UpsertUserPreferenceDto
///
/// Properties:
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
@BuiltValue()
abstract class UpsertUserPreferenceDto implements Built<UpsertUserPreferenceDto, UpsertUserPreferenceDtoBuilder> {
  @BuiltValueField(wireName: r'language')
  String? get language;

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'latitude')
  num? get latitude;

  @BuiltValueField(wireName: r'longitude')
  num? get longitude;

  @BuiltValueField(wireName: r'locationName')
  String? get locationName;

  @BuiltValueField(wireName: r'weatherEnabled')
  bool? get weatherEnabled;

  @BuiltValueField(wireName: r'themeMode')
  JsonObject? get themeMode;

  @BuiltValueField(wireName: r'themeId')
  String? get themeId;

  @BuiltValueField(wireName: r'enableCompanionBubble')
  bool? get enableCompanionBubble;

  @BuiltValueField(wireName: r'bubbleIntervalSeconds')
  num? get bubbleIntervalSeconds;

  @BuiltValueField(wireName: r'enableSound')
  bool? get enableSound;

  @BuiltValueField(wireName: r'enableHaptics')
  bool? get enableHaptics;

  @BuiltValueField(wireName: r'pushNotificationsEnabled')
  bool? get pushNotificationsEnabled;

  @BuiltValueField(wireName: r'emailNotificationsEnabled')
  bool? get emailNotificationsEnabled;

  UpsertUserPreferenceDto._();

  factory UpsertUserPreferenceDto([void updates(UpsertUserPreferenceDtoBuilder b)]) = _$UpsertUserPreferenceDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpsertUserPreferenceDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpsertUserPreferenceDto> get serializer => _$UpsertUserPreferenceDtoSerializer();
}

class _$UpsertUserPreferenceDtoSerializer implements PrimitiveSerializer<UpsertUserPreferenceDto> {
  @override
  final Iterable<Type> types = const [UpsertUserPreferenceDto, _$UpsertUserPreferenceDto];

  @override
  final String wireName = r'UpsertUserPreferenceDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpsertUserPreferenceDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.language != null) {
      yield r'language';
      yield serializers.serialize(
        object.language,
        specifiedType: const FullType(String),
      );
    }
    if (object.timezone != null) {
      yield r'timezone';
      yield serializers.serialize(
        object.timezone,
        specifiedType: const FullType(String),
      );
    }
    if (object.latitude != null) {
      yield r'latitude';
      yield serializers.serialize(
        object.latitude,
        specifiedType: const FullType(num),
      );
    }
    if (object.longitude != null) {
      yield r'longitude';
      yield serializers.serialize(
        object.longitude,
        specifiedType: const FullType(num),
      );
    }
    if (object.locationName != null) {
      yield r'locationName';
      yield serializers.serialize(
        object.locationName,
        specifiedType: const FullType(String),
      );
    }
    if (object.weatherEnabled != null) {
      yield r'weatherEnabled';
      yield serializers.serialize(
        object.weatherEnabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.themeMode != null) {
      yield r'themeMode';
      yield serializers.serialize(
        object.themeMode,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.themeId != null) {
      yield r'themeId';
      yield serializers.serialize(
        object.themeId,
        specifiedType: const FullType(String),
      );
    }
    if (object.enableCompanionBubble != null) {
      yield r'enableCompanionBubble';
      yield serializers.serialize(
        object.enableCompanionBubble,
        specifiedType: const FullType(bool),
      );
    }
    if (object.bubbleIntervalSeconds != null) {
      yield r'bubbleIntervalSeconds';
      yield serializers.serialize(
        object.bubbleIntervalSeconds,
        specifiedType: const FullType(num),
      );
    }
    if (object.enableSound != null) {
      yield r'enableSound';
      yield serializers.serialize(
        object.enableSound,
        specifiedType: const FullType(bool),
      );
    }
    if (object.enableHaptics != null) {
      yield r'enableHaptics';
      yield serializers.serialize(
        object.enableHaptics,
        specifiedType: const FullType(bool),
      );
    }
    if (object.pushNotificationsEnabled != null) {
      yield r'pushNotificationsEnabled';
      yield serializers.serialize(
        object.pushNotificationsEnabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.emailNotificationsEnabled != null) {
      yield r'emailNotificationsEnabled';
      yield serializers.serialize(
        object.emailNotificationsEnabled,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpsertUserPreferenceDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpsertUserPreferenceDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
            specifiedType: const FullType(num),
          ) as num;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.longitude = valueDes;
          break;
        case r'locationName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
            specifiedType: const FullType(String),
          ) as String;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpsertUserPreferenceDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpsertUserPreferenceDtoBuilder();
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

