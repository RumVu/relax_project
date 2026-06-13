//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'upsert_user_companion_dto.g.dart';

/// UpsertUserCompanionDto
///
/// Properties:
/// * [assetId] 
/// * [name] 
/// * [type] 
/// * [personalizationMode] 
/// * [mood] 
/// * [action] 
/// * [level] 
/// * [affection] 
/// * [energy] 
@BuiltValue()
abstract class UpsertUserCompanionDto implements Built<UpsertUserCompanionDto, UpsertUserCompanionDtoBuilder> {
  @BuiltValueField(wireName: r'assetId')
  String? get assetId;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'type')
  JsonObject? get type;

  @BuiltValueField(wireName: r'personalizationMode')
  JsonObject? get personalizationMode;

  @BuiltValueField(wireName: r'mood')
  JsonObject? get mood;

  @BuiltValueField(wireName: r'action')
  JsonObject? get action;

  @BuiltValueField(wireName: r'level')
  num? get level;

  @BuiltValueField(wireName: r'affection')
  num? get affection;

  @BuiltValueField(wireName: r'energy')
  num? get energy;

  UpsertUserCompanionDto._();

  factory UpsertUserCompanionDto([void updates(UpsertUserCompanionDtoBuilder b)]) = _$UpsertUserCompanionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpsertUserCompanionDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpsertUserCompanionDto> get serializer => _$UpsertUserCompanionDtoSerializer();
}

class _$UpsertUserCompanionDtoSerializer implements PrimitiveSerializer<UpsertUserCompanionDto> {
  @override
  final Iterable<Type> types = const [UpsertUserCompanionDto, _$UpsertUserCompanionDto];

  @override
  final String wireName = r'UpsertUserCompanionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpsertUserCompanionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.assetId != null) {
      yield r'assetId';
      yield serializers.serialize(
        object.assetId,
        specifiedType: const FullType(String),
      );
    }
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
    if (object.personalizationMode != null) {
      yield r'personalizationMode';
      yield serializers.serialize(
        object.personalizationMode,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.mood != null) {
      yield r'mood';
      yield serializers.serialize(
        object.mood,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.action != null) {
      yield r'action';
      yield serializers.serialize(
        object.action,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.level != null) {
      yield r'level';
      yield serializers.serialize(
        object.level,
        specifiedType: const FullType(num),
      );
    }
    if (object.affection != null) {
      yield r'affection';
      yield serializers.serialize(
        object.affection,
        specifiedType: const FullType(num),
      );
    }
    if (object.energy != null) {
      yield r'energy';
      yield serializers.serialize(
        object.energy,
        specifiedType: const FullType(num),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpsertUserCompanionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpsertUserCompanionDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'assetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpsertUserCompanionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpsertUserCompanionDtoBuilder();
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

