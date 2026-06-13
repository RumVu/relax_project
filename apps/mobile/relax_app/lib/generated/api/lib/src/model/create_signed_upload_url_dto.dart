//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_signed_upload_url_dto.g.dart';

/// CreateSignedUploadUrlDto
///
/// Properties:
/// * [path] 
/// * [upsert] 
@BuiltValue()
abstract class CreateSignedUploadUrlDto implements Built<CreateSignedUploadUrlDto, CreateSignedUploadUrlDtoBuilder> {
  @BuiltValueField(wireName: r'path')
  String get path;

  @BuiltValueField(wireName: r'upsert')
  bool? get upsert;

  CreateSignedUploadUrlDto._();

  factory CreateSignedUploadUrlDto([void updates(CreateSignedUploadUrlDtoBuilder b)]) = _$CreateSignedUploadUrlDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateSignedUploadUrlDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateSignedUploadUrlDto> get serializer => _$CreateSignedUploadUrlDtoSerializer();
}

class _$CreateSignedUploadUrlDtoSerializer implements PrimitiveSerializer<CreateSignedUploadUrlDto> {
  @override
  final Iterable<Type> types = const [CreateSignedUploadUrlDto, _$CreateSignedUploadUrlDto];

  @override
  final String wireName = r'CreateSignedUploadUrlDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateSignedUploadUrlDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'path';
    yield serializers.serialize(
      object.path,
      specifiedType: const FullType(String),
    );
    if (object.upsert != null) {
      yield r'upsert';
      yield serializers.serialize(
        object.upsert,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateSignedUploadUrlDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateSignedUploadUrlDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'path':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.path = valueDes;
          break;
        case r'upsert':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.upsert = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateSignedUploadUrlDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateSignedUploadUrlDtoBuilder();
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

