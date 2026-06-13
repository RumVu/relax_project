//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'app_theme_response_dto.g.dart';

/// AppThemeResponseDto
///
/// Properties:
/// * [id] 
/// * [name] 
/// * [mode] 
/// * [backgroundColor] 
/// * [surfaceColor] 
/// * [primaryColor] 
/// * [secondaryColor] 
/// * [accentColor] 
/// * [textColor] 
/// * [mutedTextColor] 
/// * [isDefault] 
/// * [isActive] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class AppThemeResponseDto implements Built<AppThemeResponseDto, AppThemeResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'name')
  String get name;

  @BuiltValueField(wireName: r'mode')
  JsonObject get mode;

  @BuiltValueField(wireName: r'backgroundColor')
  String get backgroundColor;

  @BuiltValueField(wireName: r'surfaceColor')
  String get surfaceColor;

  @BuiltValueField(wireName: r'primaryColor')
  String get primaryColor;

  @BuiltValueField(wireName: r'secondaryColor')
  String? get secondaryColor;

  @BuiltValueField(wireName: r'accentColor')
  String? get accentColor;

  @BuiltValueField(wireName: r'textColor')
  String get textColor;

  @BuiltValueField(wireName: r'mutedTextColor')
  String? get mutedTextColor;

  @BuiltValueField(wireName: r'isDefault')
  bool get isDefault;

  @BuiltValueField(wireName: r'isActive')
  bool get isActive;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  AppThemeResponseDto._();

  factory AppThemeResponseDto([void updates(AppThemeResponseDtoBuilder b)]) = _$AppThemeResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AppThemeResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AppThemeResponseDto> get serializer => _$AppThemeResponseDtoSerializer();
}

class _$AppThemeResponseDtoSerializer implements PrimitiveSerializer<AppThemeResponseDto> {
  @override
  final Iterable<Type> types = const [AppThemeResponseDto, _$AppThemeResponseDto];

  @override
  final String wireName = r'AppThemeResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AppThemeResponseDto object, {
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
    yield r'mode';
    yield serializers.serialize(
      object.mode,
      specifiedType: const FullType(JsonObject),
    );
    yield r'backgroundColor';
    yield serializers.serialize(
      object.backgroundColor,
      specifiedType: const FullType(String),
    );
    yield r'surfaceColor';
    yield serializers.serialize(
      object.surfaceColor,
      specifiedType: const FullType(String),
    );
    yield r'primaryColor';
    yield serializers.serialize(
      object.primaryColor,
      specifiedType: const FullType(String),
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
    yield r'textColor';
    yield serializers.serialize(
      object.textColor,
      specifiedType: const FullType(String),
    );
    yield r'mutedTextColor';
    yield object.mutedTextColor == null ? null : serializers.serialize(
      object.mutedTextColor,
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
    AppThemeResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AppThemeResponseDtoBuilder result,
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
        case r'mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.mode = valueDes;
          break;
        case r'backgroundColor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.backgroundColor = valueDes;
          break;
        case r'surfaceColor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.surfaceColor = valueDes;
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
        case r'textColor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.textColor = valueDes;
          break;
        case r'mutedTextColor':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.mutedTextColor = valueDes;
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
  AppThemeResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AppThemeResponseDtoBuilder();
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

