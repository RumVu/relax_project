//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:relax_api_client/src/model/companion_asset_response_dto.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'user_companion_response_dto.g.dart';

/// UserCompanionResponseDto
///
/// Properties:
/// * [id] 
/// * [userId] 
/// * [assetId] 
/// * [name] 
/// * [type] 
/// * [personalizationMode] 
/// * [mood] 
/// * [action] 
/// * [level] 
/// * [affection] 
/// * [energy] 
/// * [lastSeenAt] 
/// * [lastFedAt] 
/// * [lastMoodAt] 
/// * [createdAt] 
/// * [updatedAt] 
/// * [asset] 
@BuiltValue()
abstract class UserCompanionResponseDto implements Built<UserCompanionResponseDto, UserCompanionResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'userId')
  String get userId;

  @BuiltValueField(wireName: r'assetId')
  String? get assetId;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'type')
  JsonObject get type;

  @BuiltValueField(wireName: r'personalizationMode')
  JsonObject get personalizationMode;

  @BuiltValueField(wireName: r'mood')
  JsonObject get mood;

  @BuiltValueField(wireName: r'action')
  JsonObject get action;

  @BuiltValueField(wireName: r'level')
  num get level;

  @BuiltValueField(wireName: r'affection')
  num get affection;

  @BuiltValueField(wireName: r'energy')
  num get energy;

  @BuiltValueField(wireName: r'lastSeenAt')
  DateTime? get lastSeenAt;

  @BuiltValueField(wireName: r'lastFedAt')
  DateTime? get lastFedAt;

  @BuiltValueField(wireName: r'lastMoodAt')
  DateTime? get lastMoodAt;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  @BuiltValueField(wireName: r'asset')
  CompanionAssetResponseDto? get asset;

  UserCompanionResponseDto._();

  factory UserCompanionResponseDto([void updates(UserCompanionResponseDtoBuilder b)]) = _$UserCompanionResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UserCompanionResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UserCompanionResponseDto> get serializer => _$UserCompanionResponseDtoSerializer();
}

class _$UserCompanionResponseDtoSerializer implements PrimitiveSerializer<UserCompanionResponseDto> {
  @override
  final Iterable<Type> types = const [UserCompanionResponseDto, _$UserCompanionResponseDto];

  @override
  final String wireName = r'UserCompanionResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UserCompanionResponseDto object, {
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
    yield r'assetId';
    yield object.assetId == null ? null : serializers.serialize(
      object.assetId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
    yield r'type';
    yield serializers.serialize(
      object.type,
      specifiedType: const FullType(JsonObject),
    );
    yield r'personalizationMode';
    yield serializers.serialize(
      object.personalizationMode,
      specifiedType: const FullType(JsonObject),
    );
    yield r'mood';
    yield serializers.serialize(
      object.mood,
      specifiedType: const FullType(JsonObject),
    );
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(JsonObject),
    );
    yield r'level';
    yield serializers.serialize(
      object.level,
      specifiedType: const FullType(num),
    );
    yield r'affection';
    yield serializers.serialize(
      object.affection,
      specifiedType: const FullType(num),
    );
    yield r'energy';
    yield serializers.serialize(
      object.energy,
      specifiedType: const FullType(num),
    );
    yield r'lastSeenAt';
    yield object.lastSeenAt == null ? null : serializers.serialize(
      object.lastSeenAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'lastFedAt';
    yield object.lastFedAt == null ? null : serializers.serialize(
      object.lastFedAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'lastMoodAt';
    yield object.lastMoodAt == null ? null : serializers.serialize(
      object.lastMoodAt,
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
    if (object.asset != null) {
      yield r'asset';
      yield serializers.serialize(
        object.asset,
        specifiedType: const FullType.nullable(CompanionAssetResponseDto),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UserCompanionResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UserCompanionResponseDtoBuilder result,
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
        case r'assetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.assetId = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.type = valueDes;
          break;
        case r'personalizationMode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.personalizationMode = valueDes;
          break;
        case r'mood':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.mood = valueDes;
          break;
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.action = valueDes;
          break;
        case r'level':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.level = valueDes;
          break;
        case r'affection':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.affection = valueDes;
          break;
        case r'energy':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.energy = valueDes;
          break;
        case r'lastSeenAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastSeenAt = valueDes;
          break;
        case r'lastFedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastFedAt = valueDes;
          break;
        case r'lastMoodAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.lastMoodAt = valueDes;
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
        case r'asset':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(CompanionAssetResponseDto),
          ) as CompanionAssetResponseDto?;
          if (valueDes == null) continue;
          result.asset.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UserCompanionResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UserCompanionResponseDtoBuilder();
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

