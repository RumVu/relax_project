//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'upsert_user_profile_dto.g.dart';

/// UpsertUserProfileDto
///
/// Properties:
/// * [displayName] 
/// * [bio] 
/// * [birthday] 
/// * [avatar] - Public URL of the user's avatar (typically Supabase public-asset URL after uploading via /storage/signed-upload-url). Lives on the User record, not UserProfile — service syncs both for convenience.
@BuiltValue()
abstract class UpsertUserProfileDto implements Built<UpsertUserProfileDto, UpsertUserProfileDtoBuilder> {
  @BuiltValueField(wireName: r'displayName')
  String? get displayName;

  @BuiltValueField(wireName: r'bio')
  String? get bio;

  @BuiltValueField(wireName: r'birthday')
  DateTime? get birthday;

  /// Public URL of the user's avatar (typically Supabase public-asset URL after uploading via /storage/signed-upload-url). Lives on the User record, not UserProfile — service syncs both for convenience.
  @BuiltValueField(wireName: r'avatar')
  String? get avatar;

  UpsertUserProfileDto._();

  factory UpsertUserProfileDto([void updates(UpsertUserProfileDtoBuilder b)]) = _$UpsertUserProfileDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpsertUserProfileDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpsertUserProfileDto> get serializer => _$UpsertUserProfileDtoSerializer();
}

class _$UpsertUserProfileDtoSerializer implements PrimitiveSerializer<UpsertUserProfileDto> {
  @override
  final Iterable<Type> types = const [UpsertUserProfileDto, _$UpsertUserProfileDto];

  @override
  final String wireName = r'UpsertUserProfileDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpsertUserProfileDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.displayName != null) {
      yield r'displayName';
      yield serializers.serialize(
        object.displayName,
        specifiedType: const FullType(String),
      );
    }
    if (object.bio != null) {
      yield r'bio';
      yield serializers.serialize(
        object.bio,
        specifiedType: const FullType(String),
      );
    }
    if (object.birthday != null) {
      yield r'birthday';
      yield serializers.serialize(
        object.birthday,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.avatar != null) {
      yield r'avatar';
      yield serializers.serialize(
        object.avatar,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpsertUserProfileDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpsertUserProfileDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.displayName = valueDes;
          break;
        case r'bio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.bio = valueDes;
          break;
        case r'birthday':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.birthday = valueDes;
          break;
        case r'avatar':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.avatar = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpsertUserProfileDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpsertUserProfileDtoBuilder();
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

