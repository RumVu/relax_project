//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_cozy_quote_dto.g.dart';

/// CreateCozyQuoteDto
///
/// Properties:
/// * [content] 
/// * [author] 
/// * [mood] 
/// * [imageUrl] 
/// * [lang] 
/// * [isActive] 
@BuiltValue()
abstract class CreateCozyQuoteDto implements Built<CreateCozyQuoteDto, CreateCozyQuoteDtoBuilder> {
  @BuiltValueField(wireName: r'content')
  String get content;

  @BuiltValueField(wireName: r'author')
  String? get author;

  @BuiltValueField(wireName: r'mood')
  JsonObject? get mood;

  @BuiltValueField(wireName: r'imageUrl')
  String? get imageUrl;

  @BuiltValueField(wireName: r'lang')
  String? get lang;

  @BuiltValueField(wireName: r'isActive')
  bool? get isActive;

  CreateCozyQuoteDto._();

  factory CreateCozyQuoteDto([void updates(CreateCozyQuoteDtoBuilder b)]) = _$CreateCozyQuoteDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateCozyQuoteDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateCozyQuoteDto> get serializer => _$CreateCozyQuoteDtoSerializer();
}

class _$CreateCozyQuoteDtoSerializer implements PrimitiveSerializer<CreateCozyQuoteDto> {
  @override
  final Iterable<Type> types = const [CreateCozyQuoteDto, _$CreateCozyQuoteDto];

  @override
  final String wireName = r'CreateCozyQuoteDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateCozyQuoteDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    if (object.author != null) {
      yield r'author';
      yield serializers.serialize(
        object.author,
        specifiedType: const FullType(String),
      );
    }
    if (object.mood != null) {
      yield r'mood';
      yield serializers.serialize(
        object.mood,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.imageUrl != null) {
      yield r'imageUrl';
      yield serializers.serialize(
        object.imageUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.lang != null) {
      yield r'lang';
      yield serializers.serialize(
        object.lang,
        specifiedType: const FullType(String),
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
    CreateCozyQuoteDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateCozyQuoteDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
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
            specifiedType: const FullType(String),
          ) as String;
          result.author = valueDes;
          break;
        case r'mood':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.mood = valueDes;
          break;
        case r'imageUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
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
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateCozyQuoteDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateCozyQuoteDtoBuilder();
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

