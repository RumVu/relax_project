//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'storage_file_response_dto.g.dart';

/// StorageFileResponseDto
///
/// Properties:
/// * [id] 
/// * [userId] 
/// * [filename] 
/// * [mimetype] 
/// * [size] 
/// * [provider] 
/// * [path] 
/// * [url] 
/// * [publicUrl] 
/// * [bucket] 
/// * [isPublic] 
/// * [expiresAt] 
/// * [createdAt] 
@BuiltValue()
abstract class StorageFileResponseDto implements Built<StorageFileResponseDto, StorageFileResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'userId')
  String? get userId;

  @BuiltValueField(wireName: r'filename')
  String get filename;

  @BuiltValueField(wireName: r'mimetype')
  String get mimetype;

  @BuiltValueField(wireName: r'size')
  num get size;

  @BuiltValueField(wireName: r'provider')
  String get provider;

  @BuiltValueField(wireName: r'path')
  String? get path;

  @BuiltValueField(wireName: r'url')
  String get url;

  @BuiltValueField(wireName: r'publicUrl')
  String? get publicUrl;

  @BuiltValueField(wireName: r'bucket')
  String? get bucket;

  @BuiltValueField(wireName: r'isPublic')
  bool get isPublic;

  @BuiltValueField(wireName: r'expiresAt')
  DateTime? get expiresAt;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  StorageFileResponseDto._();

  factory StorageFileResponseDto([void updates(StorageFileResponseDtoBuilder b)]) = _$StorageFileResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(StorageFileResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<StorageFileResponseDto> get serializer => _$StorageFileResponseDtoSerializer();
}

class _$StorageFileResponseDtoSerializer implements PrimitiveSerializer<StorageFileResponseDto> {
  @override
  final Iterable<Type> types = const [StorageFileResponseDto, _$StorageFileResponseDto];

  @override
  final String wireName = r'StorageFileResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    StorageFileResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'userId';
    yield object.userId == null ? null : serializers.serialize(
      object.userId,
      specifiedType: const FullType.nullable(String),
    );
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
    yield r'provider';
    yield serializers.serialize(
      object.provider,
      specifiedType: const FullType(String),
    );
    yield r'path';
    yield object.path == null ? null : serializers.serialize(
      object.path,
      specifiedType: const FullType.nullable(String),
    );
    yield r'url';
    yield serializers.serialize(
      object.url,
      specifiedType: const FullType(String),
    );
    yield r'publicUrl';
    yield object.publicUrl == null ? null : serializers.serialize(
      object.publicUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'bucket';
    yield object.bucket == null ? null : serializers.serialize(
      object.bucket,
      specifiedType: const FullType.nullable(String),
    );
    yield r'isPublic';
    yield serializers.serialize(
      object.isPublic,
      specifiedType: const FullType(bool),
    );
    yield r'expiresAt';
    yield object.expiresAt == null ? null : serializers.serialize(
      object.expiresAt,
      specifiedType: const FullType.nullable(DateTime),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    StorageFileResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required StorageFileResponseDtoBuilder result,
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
        case r'userId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.userId = valueDes;
          break;
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
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.provider = valueDes;
          break;
        case r'path':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.path = valueDes;
          break;
        case r'url':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.url = valueDes;
          break;
        case r'publicUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.publicUrl = valueDes;
          break;
        case r'bucket':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.bucket = valueDes;
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
            specifiedType: const FullType.nullable(DateTime),
          ) as DateTime?;
          if (valueDes == null) continue;
          result.expiresAt = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  StorageFileResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = StorageFileResponseDtoBuilder();
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

