//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'switch_companion_personalization_dto.g.dart';

/// SwitchCompanionPersonalizationDto
///
/// Properties:
/// * [personalizationMode] 
/// * [assetId] 
/// * [preserveProgress] 
/// * [resetVisualState] 
@BuiltValue()
abstract class SwitchCompanionPersonalizationDto implements Built<SwitchCompanionPersonalizationDto, SwitchCompanionPersonalizationDtoBuilder> {
  @BuiltValueField(wireName: r'personalizationMode')
  JsonObject get personalizationMode;

  @BuiltValueField(wireName: r'assetId')
  String? get assetId;

  @BuiltValueField(wireName: r'preserveProgress')
  bool? get preserveProgress;

  @BuiltValueField(wireName: r'resetVisualState')
  bool? get resetVisualState;

  SwitchCompanionPersonalizationDto._();

  factory SwitchCompanionPersonalizationDto([void updates(SwitchCompanionPersonalizationDtoBuilder b)]) = _$SwitchCompanionPersonalizationDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(SwitchCompanionPersonalizationDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<SwitchCompanionPersonalizationDto> get serializer => _$SwitchCompanionPersonalizationDtoSerializer();
}

class _$SwitchCompanionPersonalizationDtoSerializer implements PrimitiveSerializer<SwitchCompanionPersonalizationDto> {
  @override
  final Iterable<Type> types = const [SwitchCompanionPersonalizationDto, _$SwitchCompanionPersonalizationDto];

  @override
  final String wireName = r'SwitchCompanionPersonalizationDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    SwitchCompanionPersonalizationDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'personalizationMode';
    yield serializers.serialize(
      object.personalizationMode,
      specifiedType: const FullType(JsonObject),
    );
    if (object.assetId != null) {
      yield r'assetId';
      yield serializers.serialize(
        object.assetId,
        specifiedType: const FullType(String),
      );
    }
    if (object.preserveProgress != null) {
      yield r'preserveProgress';
      yield serializers.serialize(
        object.preserveProgress,
        specifiedType: const FullType(bool),
      );
    }
    if (object.resetVisualState != null) {
      yield r'resetVisualState';
      yield serializers.serialize(
        object.resetVisualState,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    SwitchCompanionPersonalizationDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required SwitchCompanionPersonalizationDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'personalizationMode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.personalizationMode = valueDes;
          break;
        case r'assetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.assetId = valueDes;
          break;
        case r'preserveProgress':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.preserveProgress = valueDes;
          break;
        case r'resetVisualState':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.resetVisualState = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  SwitchCompanionPersonalizationDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = SwitchCompanionPersonalizationDtoBuilder();
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

