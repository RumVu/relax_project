//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_experiment_dto.g.dart';

/// UpdateExperimentDto
///
/// Properties:
/// * [key] 
/// * [name] 
/// * [description] 
/// * [variants] 
/// * [isActive] 
@BuiltValue()
abstract class UpdateExperimentDto implements Built<UpdateExperimentDto, UpdateExperimentDtoBuilder> {
  @BuiltValueField(wireName: r'key')
  String? get key;

  @BuiltValueField(wireName: r'name')
  String? get name;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'variants')
  BuiltList<String>? get variants;

  @BuiltValueField(wireName: r'isActive')
  bool? get isActive;

  UpdateExperimentDto._();

  factory UpdateExperimentDto([void updates(UpdateExperimentDtoBuilder b)]) = _$UpdateExperimentDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateExperimentDtoBuilder b) => b
      ..isActive = true;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateExperimentDto> get serializer => _$UpdateExperimentDtoSerializer();
}

class _$UpdateExperimentDtoSerializer implements PrimitiveSerializer<UpdateExperimentDto> {
  @override
  final Iterable<Type> types = const [UpdateExperimentDto, _$UpdateExperimentDto];

  @override
  final String wireName = r'UpdateExperimentDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateExperimentDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.key != null) {
      yield r'key';
      yield serializers.serialize(
        object.key,
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
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    if (object.variants != null) {
      yield r'variants';
      yield serializers.serialize(
        object.variants,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
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
    UpdateExperimentDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateExperimentDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'key':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.key = valueDes;
          break;
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'variants':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.variants.replace(valueDes);
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
  UpdateExperimentDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateExperimentDtoBuilder();
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

