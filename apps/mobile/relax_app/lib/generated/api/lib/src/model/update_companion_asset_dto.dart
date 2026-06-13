//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_companion_asset_dto.g.dart';

/// UpdateCompanionAssetDto
///
/// Properties:
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
/// * [isDefault] 
/// * [isActive] 
@BuiltValue()
abstract class UpdateCompanionAssetDto implements Built<UpdateCompanionAssetDto, UpdateCompanionAssetDtoBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'type')
  JsonObject? get type;

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

  @BuiltValueField(wireName: r'isDefault')
  bool? get isDefault;

  @BuiltValueField(wireName: r'isActive')
  bool? get isActive;

  UpdateCompanionAssetDto._();

  factory UpdateCompanionAssetDto([void updates(UpdateCompanionAssetDtoBuilder b)]) = _$UpdateCompanionAssetDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateCompanionAssetDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateCompanionAssetDto> get serializer => _$UpdateCompanionAssetDtoSerializer();
}

class _$UpdateCompanionAssetDtoSerializer implements PrimitiveSerializer<UpdateCompanionAssetDto> {
  @override
  final Iterable<Type> types = const [UpdateCompanionAssetDto, _$UpdateCompanionAssetDto];

  @override
  final String wireName = r'UpdateCompanionAssetDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateCompanionAssetDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    if (object.previewImageUrl != null) {
      yield r'previewImageUrl';
      yield serializers.serialize(
        object.previewImageUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.spriteSheetUrl != null) {
      yield r'spriteSheetUrl';
      yield serializers.serialize(
        object.spriteSheetUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.idleAnimationUrl != null) {
      yield r'idleAnimationUrl';
      yield serializers.serialize(
        object.idleAnimationUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.sleepAnimationUrl != null) {
      yield r'sleepAnimationUrl';
      yield serializers.serialize(
        object.sleepAnimationUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.walkAnimationUrl != null) {
      yield r'walkAnimationUrl';
      yield serializers.serialize(
        object.walkAnimationUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.primaryColor != null) {
      yield r'primaryColor';
      yield serializers.serialize(
        object.primaryColor,
        specifiedType: const FullType(String),
      );
    }
    if (object.secondaryColor != null) {
      yield r'secondaryColor';
      yield serializers.serialize(
        object.secondaryColor,
        specifiedType: const FullType(String),
      );
    }
    if (object.accentColor != null) {
      yield r'accentColor';
      yield serializers.serialize(
        object.accentColor,
        specifiedType: const FullType(String),
      );
    }
    if (object.isDefault != null) {
      yield r'isDefault';
      yield serializers.serialize(
        object.isDefault,
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
    UpdateCompanionAssetDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateCompanionAssetDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'previewImageUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.previewImageUrl = valueDes;
          break;
        case r'spriteSheetUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.spriteSheetUrl = valueDes;
          break;
        case r'idleAnimationUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.idleAnimationUrl = valueDes;
          break;
        case r'sleepAnimationUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.sleepAnimationUrl = valueDes;
          break;
        case r'walkAnimationUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.walkAnimationUrl = valueDes;
          break;
        case r'primaryColor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.primaryColor = valueDes;
          break;
        case r'secondaryColor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.secondaryColor = valueDes;
          break;
        case r'accentColor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accentColor = valueDes;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateCompanionAssetDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateCompanionAssetDtoBuilder();
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

