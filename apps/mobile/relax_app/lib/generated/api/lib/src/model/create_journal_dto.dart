//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_journal_dto.g.dart';

/// CreateJournalDto
///
/// Properties:
/// * [title] 
/// * [content] 
/// * [mood] 
/// * [tags] 
/// * [isPrivate] 
/// * [isFavorite] 
@BuiltValue()
abstract class CreateJournalDto implements Built<CreateJournalDto, CreateJournalDtoBuilder> {
  @BuiltValueField(wireName: r'title')
  String? get title;

  @BuiltValueField(wireName: r'content')
  String get content;

  @BuiltValueField(wireName: r'mood')
  JsonObject? get mood;

  @BuiltValueField(wireName: r'tags')
  BuiltList<String>? get tags;

  @BuiltValueField(wireName: r'isPrivate')
  bool? get isPrivate;

  @BuiltValueField(wireName: r'isFavorite')
  bool? get isFavorite;

  CreateJournalDto._();

  factory CreateJournalDto([void updates(CreateJournalDtoBuilder b)]) = _$CreateJournalDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateJournalDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateJournalDto> get serializer => _$CreateJournalDtoSerializer();
}

class _$CreateJournalDtoSerializer implements PrimitiveSerializer<CreateJournalDto> {
  @override
  final Iterable<Type> types = const [CreateJournalDto, _$CreateJournalDto];

  @override
  final String wireName = r'CreateJournalDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateJournalDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    yield r'content';
    yield serializers.serialize(
      object.content,
      specifiedType: const FullType(String),
    );
    if (object.mood != null) {
      yield r'mood';
      yield serializers.serialize(
        object.mood,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.tags != null) {
      yield r'tags';
      yield serializers.serialize(
        object.tags,
        specifiedType: const FullType(BuiltList, [FullType(String)]),
      );
    }
    if (object.isPrivate != null) {
      yield r'isPrivate';
      yield serializers.serialize(
        object.isPrivate,
        specifiedType: const FullType(bool),
      );
    }
    if (object.isFavorite != null) {
      yield r'isFavorite';
      yield serializers.serialize(
        object.isFavorite,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateJournalDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateJournalDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'content':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.content = valueDes;
          break;
        case r'mood':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.mood = valueDes;
          break;
        case r'tags':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(String)]),
          ) as BuiltList<String>;
          result.tags.replace(valueDes);
          break;
        case r'isPrivate':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isPrivate = valueDes;
          break;
        case r'isFavorite':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isFavorite = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateJournalDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateJournalDtoBuilder();
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

