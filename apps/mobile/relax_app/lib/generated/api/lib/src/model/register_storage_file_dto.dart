//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'register_storage_file_dto.g.dart';

/// RegisterStorageFileDto
///
/// Properties:
/// * [filename] 
/// * [mimetype] 
/// * [size] 
/// * [path] 
/// * [publicUrl] 
/// * [isPublic] 
/// * [expiresAt] 
/// * [metadata] 
@BuiltValue()
abstract class RegisterStorageFileDto implements Built<RegisterStorageFileDto, RegisterStorageFileDtoBuilder> {
  @BuiltValueField(wireName: r'filename')
  String get filename;

  @BuiltValueField(wireName: r'mimetype')
  String get mimetype;

  @BuiltValueField(wireName: r'size')
  num get size;

  @BuiltValueField(wireName: r'path')
  String get path;

  @BuiltValueField(wireName: r'publicUrl')
  String? get publicUrl;

  @BuiltValueField(wireName: r'isPublic')
  bool? get isPublic;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime? get expiresAt;

  @BuiltValueField(wireName: r'metadata')
  JsonObject? get metadata;

  RegisterStorageFileDto._();

  factory RegisterStorageFileDto([void updates(RegisterStorageFileDtoBuilder b)]) = _$RegisterStorageFileDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RegisterStorageFileDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RegisterStorageFileDto> get serializer => _$RegisterStorageFileDtoSerializer();
}

class _$RegisterStorageFileDtoSerializer implements PrimitiveSerializer<RegisterStorageFileDto> {
  @override
  final Iterable<Type> types = const [RegisterStorageFileDto, _$RegisterStorageFileDto];

  @override
  final String wireName = r'RegisterStorageFileDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RegisterStorageFileDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'filename';
    yield serializers.serialize(
      object.filename,
      specifiedType: const FullType(String),
    );
    yield r'mimetype';
    yield serializers.serialize(
      object.mimetype,
      specifiedType: const FullType(String),
    );
    yield r'size';
    yield serializers.serialize(
      object.size,
      specifiedType: const FullType(num),
    );
    yield r'path';
    yield serializers.serialize(
      object.path,
      specifiedType: const FullType(String),
    );
    if (object.publicUrl != null) {
      yield r'publicUrl';
      yield serializers.serialize(
        object.publicUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.isPublic != null) {
      yield r'isPublic';
      yield serializers.serialize(
        object.isPublic,
        specifiedType: const FullType(bool),
      );
    }
    if (object.expiresAt != null) {
      yield r'expiresAt';
      yield serializers.serialize(
        object.expiresAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.metadata != null) {
      yield r'metadata';
      yield serializers.serialize(
        object.metadata,
        specifiedType: const FullType(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RegisterStorageFileDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RegisterStorageFileDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'filename':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.filename = valueDes;
          break;
        case r'mimetype':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.mimetype = valueDes;
          break;
        case r'size':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.size = valueDes;
          break;
        case r'path':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.path = valueDes;
          break;
        case r'publicUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.publicUrl = valueDes;
          break;
        case r'isPublic':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isPublic = valueDes;
          break;
        case r'expiresAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.expiresAt = valueDes;
          break;
        case r'metadata':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.metadata = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RegisterStorageFileDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RegisterStorageFileDtoBuilder();
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

