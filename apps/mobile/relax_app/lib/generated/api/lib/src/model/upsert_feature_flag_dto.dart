//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'upsert_feature_flag_dto.g.dart';

/// UpsertFeatureFlagDto
///
/// Properties:
/// * [key] 
/// * [label] 
/// * [description] 
/// * [enabled] 
@BuiltValue()
abstract class UpsertFeatureFlagDto implements Built<UpsertFeatureFlagDto, UpsertFeatureFlagDtoBuilder> {
  @BuiltValueField(wireName: r'key')
  String get key;

  @BuiltValueField(wireName: r'label')
  String get label;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'enabled')
  bool get enabled;

  UpsertFeatureFlagDto._();

  factory UpsertFeatureFlagDto([void updates(UpsertFeatureFlagDtoBuilder b)]) = _$UpsertFeatureFlagDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpsertFeatureFlagDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpsertFeatureFlagDto> get serializer => _$UpsertFeatureFlagDtoSerializer();
}

class _$UpsertFeatureFlagDtoSerializer implements PrimitiveSerializer<UpsertFeatureFlagDto> {
  @override
  final Iterable<Type> types = const [UpsertFeatureFlagDto, _$UpsertFeatureFlagDto];

  @override
  final String wireName = r'UpsertFeatureFlagDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpsertFeatureFlagDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'key';
    yield serializers.serialize(
      object.key,
      specifiedType: const FullType(String),
    );
    yield r'label';
    yield serializers.serialize(
      object.label,
      specifiedType: const FullType(String),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    yield r'enabled';
    yield serializers.serialize(
      object.enabled,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UpsertFeatureFlagDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpsertFeatureFlagDtoBuilder result,
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
        case r'label':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.label = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpsertFeatureFlagDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpsertFeatureFlagDtoBuilder();
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

