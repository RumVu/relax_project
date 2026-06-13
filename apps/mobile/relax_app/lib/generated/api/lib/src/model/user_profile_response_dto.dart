//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_profile_response_dto.g.dart';

/// UserProfileResponseDto
///
/// Properties:
/// * [id] 
/// * [userId] 
/// * [displayName] 
/// * [bio] 
/// * [avatar] 
/// * [birthday] 
/// * [zodiacSign] 
/// * [chineseZodiac] 
/// * [totalMoodCheckins] 
/// * [totalJournalPosts] 
/// * [currentStreak] 
/// * [longestStreak] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class UserProfileResponseDto implements Built<UserProfileResponseDto, UserProfileResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'displayName')
  String? get displayName;

  @BuiltValueField(wireName: r'bio')
  String? get bio;

  @BuiltValueField(wireName: r'avatar')
  String? get avatar;

  @BuiltValueField(wireName: r'birthday')
  DateTime? get birthday;

  @BuiltValueField(wireName: r'zodiacSign')
  String? get zodiacSign;

  @BuiltValueField(wireName: r'chineseZodiac')
  String? get chineseZodiac;

  @BuiltValueField(wireName: r'totalMoodCheckins')
  num get totalMoodCheckins;

  @BuiltValueField(wireName: r'totalJournalPosts')
  num get totalJournalPosts;

  @BuiltValueField(wireName: r'currentStreak')
  num get currentStreak;

  @BuiltValueField(wireName: r'longestStreak')
  num get longestStreak;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  UserProfileResponseDto._();

  factory UserProfileResponseDto([void updates(UserProfileResponseDtoBuilder b)]) = _$UserProfileResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserProfileResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserProfileResponseDto> get serializer => _$UserProfileResponseDtoSerializer();
}

class _$UserProfileResponseDtoSerializer implements PrimitiveSerializer<UserProfileResponseDto> {
  @override
  final Iterable<Type> types = const [UserProfileResponseDto, _$UserProfileResponseDto];

  @override
  final String wireName = r'UserProfileResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserProfileResponseDto object, {
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
    yield r'displayName';
    yield object.displayName == null ? null : serializers.serialize(
      object.displayName,
      specifiedType: const FullType.nullable(String),
    );
    yield r'bio';
    yield object.bio == null ? null : serializers.serialize(
      object.bio,
      specifiedType: const FullType.nullable(String),
    );
    if (object.avatar != null) {
      yield r'avatar';
      yield serializers.serialize(
        object.avatar,
        specifiedType: const FullType.nullable(String),
      );
    }
    yield r'birthday';
    yield object.birthday == null ? null : serializers.serialize(
      object.birthday,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'zodiacSign';
    yield object.zodiacSign == null ? null : serializers.serialize(
      object.zodiacSign,
      specifiedType: const FullType.nullable(String),
    );
    yield r'chineseZodiac';
    yield object.chineseZodiac == null ? null : serializers.serialize(
      object.chineseZodiac,
      specifiedType: const FullType.nullable(String),
    );
    yield r'totalMoodCheckins';
    yield serializers.serialize(
      object.totalMoodCheckins,
      specifiedType: const FullType(num),
    );
    yield r'totalJournalPosts';
    yield serializers.serialize(
      object.totalJournalPosts,
      specifiedType: const FullType(num),
    );
    yield r'currentStreak';
    yield serializers.serialize(
      object.currentStreak,
      specifiedType: const FullType(num),
    );
    yield r'longestStreak';
    yield serializers.serialize(
      object.longestStreak,
      specifiedType: const FullType(num),
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
    UserProfileResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserProfileResponseDtoBuilder result,
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
        case r'displayName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.displayName = valueDes;
          break;
        case r'bio':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.bio = valueDes;
          break;
        case r'avatar':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.avatar = valueDes;
          break;
        case r'birthday':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.birthday = valueDes;
          break;
        case r'zodiacSign':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.zodiacSign = valueDes;
          break;
        case r'chineseZodiac':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.chineseZodiac = valueDes;
          break;
        case r'totalMoodCheckins':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.totalMoodCheckins = valueDes;
          break;
        case r'totalJournalPosts':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.totalJournalPosts = valueDes;
          break;
        case r'currentStreak':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.currentStreak = valueDes;
          break;
        case r'longestStreak':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.longestStreak = valueDes;
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
  UserProfileResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserProfileResponseDtoBuilder();
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

