//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'companion_asset_response_dto.g.dart';

/// CompanionAssetResponseDto
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [type] 
/// * [description] 
/// * [previewImageUrl] 
/// * [spriteSheetUrl] 
/// * [idleAnimationUrl] 
/// * [sleepAnimationUrl] 
/// * [walkAnimationUrl] 
/// * [primaryColor] 
/// * [secondaryColor] 
/// * [accentColor] 
/// * [zodiacSign] 
/// * [chineseZodiac] 
/// * [isDefault] 
/// * [isActive] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class CompanionAssetResponseDto implements Built<CompanionAssetResponseDto, CompanionAssetResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'type')
  JsonObject get type;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'previewImageUrl')
  String? get previewImageUrl;

  @BuiltValueField(wireName: r'spriteSheetUrl')
  String? get spriteSheetUrl;

  @BuiltValueField(wireName: r'idleAnimationUrl')
  String? get idleAnimationUrl;

  @BuiltValueField(wireName: r'sleepAnimationUrl')
  String? get sleepAnimationUrl;

  @BuiltValueField(wireName: r'walkAnimationUrl')
  String? get walkAnimationUrl;

  @BuiltValueField(wireName: r'primaryColor')
  String? get primaryColor;

  @BuiltValueField(wireName: r'secondaryColor')
  String? get secondaryColor;

  @BuiltValueField(wireName: r'accentColor')
  String? get accentColor;

  @BuiltValueField(wireName: r'zodiacSign')
  String? get zodiacSign;

  @BuiltValueField(wireName: r'chineseZodiac')
  String? get chineseZodiac;

  @BuiltValueField(wireName: r'isDefault')
  bool get isDefault;

  @BuiltValueField(wireName: r'isActive')
  bool get isActive;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  CompanionAssetResponseDto._();

  factory CompanionAssetResponseDto([void updates(CompanionAssetResponseDtoBuilder b)]) = _$CompanionAssetResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CompanionAssetResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CompanionAssetResponseDto> get serializer => _$CompanionAssetResponseDtoSerializer();
}

class _$CompanionAssetResponseDtoSerializer implements PrimitiveSerializer<CompanionAssetResponseDto> {
  @override
  final Iterable<Type> types = const [CompanionAssetResponseDto, _$CompanionAssetResponseDto];

  @override
  final String wireName = r'CompanionAssetResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CompanionAssetResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
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
    yield r'description';
    yield object.description == null ? null : serializers.serialize(
      object.description,
      specifiedType: const FullType.nullable(String),
    );
    yield r'previewImageUrl';
    yield object.previewImageUrl == null ? null : serializers.serialize(
      object.previewImageUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'spriteSheetUrl';
    yield object.spriteSheetUrl == null ? null : serializers.serialize(
      object.spriteSheetUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'idleAnimationUrl';
    yield object.idleAnimationUrl == null ? null : serializers.serialize(
      object.idleAnimationUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'sleepAnimationUrl';
    yield object.sleepAnimationUrl == null ? null : serializers.serialize(
      object.sleepAnimationUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'walkAnimationUrl';
    yield object.walkAnimationUrl == null ? null : serializers.serialize(
      object.walkAnimationUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'primaryColor';
    yield object.primaryColor == null ? null : serializers.serialize(
      object.primaryColor,
      specifiedType: const FullType.nullable(String),
    );
    yield r'secondaryColor';
    yield object.secondaryColor == null ? null : serializers.serialize(
      object.secondaryColor,
      specifiedType: const FullType.nullable(String),
    );
    yield r'accentColor';
    yield object.accentColor == null ? null : serializers.serialize(
      object.accentColor,
      specifiedType: const FullType.nullable(String),
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
    yield r'isDefault';
    yield serializers.serialize(
      object.isDefault,
      specifiedType: const FullType(bool),
    );
    yield r'isActive';
    yield serializers.serialize(
      object.isActive,
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
    CompanionAssetResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CompanionAssetResponseDtoBuilder result,
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
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.description = valueDes;
          break;
        case r'previewImageUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.previewImageUrl = valueDes;
          break;
        case r'spriteSheetUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.spriteSheetUrl = valueDes;
          break;
        case r'idleAnimationUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.idleAnimationUrl = valueDes;
          break;
        case r'sleepAnimationUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.sleepAnimationUrl = valueDes;
          break;
        case r'walkAnimationUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.walkAnimationUrl = valueDes;
          break;
        case r'primaryColor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.primaryColor = valueDes;
          break;
        case r'secondaryColor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.secondaryColor = valueDes;
          break;
        case r'accentColor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.accentColor = valueDes;
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
        case r'isDefault':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isDefault = valueDes;
          break;
        case r'isActive':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isActive = valueDes;
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
  CompanionAssetResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CompanionAssetResponseDtoBuilder();
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

