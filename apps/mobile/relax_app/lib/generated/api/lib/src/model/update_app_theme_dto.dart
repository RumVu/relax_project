//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_app_theme_dto.g.dart';

/// UpdateAppThemeDto
///
/// Properties:
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
@BuiltValue()
abstract class UpdateAppThemeDto implements Built<UpdateAppThemeDto, UpdateAppThemeDtoBuilder> {
  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'mode')
  JsonObject? get mode;

  @BuiltValueField(wireName: r'backgroundColor')
  String? get backgroundColor;

  @BuiltValueField(wireName: r'surfaceColor')
  String? get surfaceColor;

  @BuiltValueField(wireName: r'primaryColor')
  String? get primaryColor;

  @BuiltValueField(wireName: r'secondaryColor')
  String? get secondaryColor;

  @BuiltValueField(wireName: r'accentColor')
  String? get accentColor;

  @BuiltValueField(wireName: r'textColor')
  String? get textColor;

  @BuiltValueField(wireName: r'mutedTextColor')
  String? get mutedTextColor;

  @BuiltValueField(wireName: r'isDefault')
  bool? get isDefault;

  @BuiltValueField(wireName: r'isActive')
  bool? get isActive;

  UpdateAppThemeDto._();

  factory UpdateAppThemeDto([void updates(UpdateAppThemeDtoBuilder b)]) = _$UpdateAppThemeDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateAppThemeDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateAppThemeDto> get serializer => _$UpdateAppThemeDtoSerializer();
}

class _$UpdateAppThemeDtoSerializer implements PrimitiveSerializer<UpdateAppThemeDto> {
  @override
  final Iterable<Type> types = const [UpdateAppThemeDto, _$UpdateAppThemeDto];

  @override
  final String wireName = r'UpdateAppThemeDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateAppThemeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.name != null) {
      yield r'name';
      yield serializers.serialize(
        object.name,
        specifiedType: const FullType(String),
      );
    }
    if (object.mode != null) {
      yield r'mode';
      yield serializers.serialize(
        object.mode,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.backgroundColor != null) {
      yield r'backgroundColor';
      yield serializers.serialize(
        object.backgroundColor,
        specifiedType: const FullType(String),
      );
    }
    if (object.surfaceColor != null) {
      yield r'surfaceColor';
      yield serializers.serialize(
        object.surfaceColor,
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
    if (object.textColor != null) {
      yield r'textColor';
      yield serializers.serialize(
        object.textColor,
        specifiedType: const FullType(String),
      );
    }
    if (object.mutedTextColor != null) {
      yield r'mutedTextColor';
      yield serializers.serialize(
        object.mutedTextColor,
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
    UpdateAppThemeDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateAppThemeDtoBuilder result,
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
            specifiedType: const FullType(String),
          ) as String;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateAppThemeDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateAppThemeDtoBuilder();
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

