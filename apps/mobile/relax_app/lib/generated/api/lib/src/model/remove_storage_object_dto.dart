//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'remove_storage_object_dto.g.dart';

/// RemoveStorageObjectDto
///
/// Properties:
/// * [paths] 
@BuiltValue()
abstract class RemoveStorageObjectDto implements Built<RemoveStorageObjectDto, RemoveStorageObjectDtoBuilder> {
  @BuiltValueField(wireName: r'paths')
  BuiltList<String> get paths;

  RemoveStorageObjectDto._();

  factory RemoveStorageObjectDto([void updates(RemoveStorageObjectDtoBuilder b)]) = _$RemoveStorageObjectDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RemoveStorageObjectDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RemoveStorageObjectDto> get serializer => _$RemoveStorageObjectDtoSerializer();
}

class _$RemoveStorageObjectDtoSerializer implements PrimitiveSerializer<RemoveStorageObjectDto> {
  @override
  final Iterable<Type> types = const [RemoveStorageObjectDto, _$RemoveStorageObjectDto];

  @override
  final String wireName = r'RemoveStorageObjectDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RemoveStorageObjectDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'paths';
    yield serializers.serialize(
      object.paths,
      specifiedType: const FullType(BuiltList, [FullType(String)]),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RemoveStorageObjectDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RemoveStorageObjectDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'paths':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.paths.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RemoveStorageObjectDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RemoveStorageObjectDtoBuilder();
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

