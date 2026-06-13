//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'companion_chat_dto.g.dart';

/// CompanionChatDto
///
/// Properties:
/// * [message] 
@BuiltValue()
abstract class CompanionChatDto implements Built<CompanionChatDto, CompanionChatDtoBuilder> {
  @BuiltValueField(wireName: r'message')
  String get message;

  CompanionChatDto._();

  factory CompanionChatDto([void updates(CompanionChatDtoBuilder b)]) = _$CompanionChatDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CompanionChatDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CompanionChatDto> get serializer => _$CompanionChatDtoSerializer();
}

class _$CompanionChatDtoSerializer implements PrimitiveSerializer<CompanionChatDto> {
  @override
  final Iterable<Type> types = const [CompanionChatDto, _$CompanionChatDto];

  @override
  final String wireName = r'CompanionChatDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CompanionChatDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CompanionChatDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CompanionChatDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CompanionChatDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CompanionChatDtoBuilder();
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

