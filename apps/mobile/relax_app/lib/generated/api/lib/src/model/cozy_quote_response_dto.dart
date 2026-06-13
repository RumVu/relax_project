//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'cozy_quote_response_dto.g.dart';

/// CozyQuoteResponseDto
///
/// Properties:
/// * [id] 
/// * [content] 
/// * [author] 
/// * [mood] 
/// * [imageUrl] 
/// * [lang] 
/// * [isActive] 
/// * [createdAt] 
/// * [updatedAt] 
@BuiltValue()
abstract class CozyQuoteResponseDto implements Built<CozyQuoteResponseDto, CozyQuoteResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'content')
  String get content;

  @BuiltValueField(wireName: r'author')
  String? get author;

  @BuiltValueField(wireName: r'mood')
  JsonObject? get mood;

  @BuiltValueField(wireName: r'imageUrl')
  String? get imageUrl;

  @BuiltValueField(wireName: r'lang')
  String get lang;

  @BuiltValueField(wireName: r'isActive')
  bool get isActive;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'updatedAt')
  DateTime get updatedAt;

  CozyQuoteResponseDto._();

  factory CozyQuoteResponseDto([void updates(CozyQuoteResponseDtoBuilder b)]) = _$CozyQuoteResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CozyQuoteResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CozyQuoteResponseDto> get serializer => _$CozyQuoteResponseDtoSerializer();
}

class _$CozyQuoteResponseDtoSerializer implements PrimitiveSerializer<CozyQuoteResponseDto> {
  @override
  final Iterable<Type> types = const [CozyQuoteResponseDto, _$CozyQuoteResponseDto];

  @override
  final String wireName = r'CozyQuoteResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CozyQuoteResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    yield r'author';
    yield object.author == null ? null : serializers.serialize(
      object.author,
      specifiedType: const FullType.nullable(String),
    );
    yield r'mood';
    yield object.mood == null ? null : serializers.serialize(
      object.mood,
      specifiedType: const FullType.nullable(JsonObject),
    );
    yield r'imageUrl';
    yield object.imageUrl == null ? null : serializers.serialize(
      object.imageUrl,
      specifiedType: const FullType.nullable(String),
    );
    yield r'lang';
    yield serializers.serialize(
      object.lang,
      specifiedType: const FullType(String),
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
    CozyQuoteResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CozyQuoteResponseDtoBuilder result,
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
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'author':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.author = valueDes;
          break;
        case r'mood':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.mood = valueDes;
          break;
        case r'imageUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.imageUrl = valueDes;
          break;
        case r'lang':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.lang = valueDes;
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
  CozyQuoteResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CozyQuoteResponseDtoBuilder();
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

