//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'check_content_dto.g.dart';

/// CheckContentDto
///
/// Properties:
/// * [text] 
@BuiltValue()
abstract class CheckContentDto implements Built<CheckContentDto, CheckContentDtoBuilder> {
  @BuiltValueField(wireName: r'text')
  String get text;

  CheckContentDto._();

  factory CheckContentDto([void updates(CheckContentDtoBuilder b)]) = _$CheckContentDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CheckContentDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CheckContentDto> get serializer => _$CheckContentDtoSerializer();
}

class _$CheckContentDtoSerializer implements PrimitiveSerializer<CheckContentDto> {
  @override
  final Iterable<Type> types = const [CheckContentDto, _$CheckContentDto];

  @override
  final String wireName = r'CheckContentDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CheckContentDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'text';
    yield serializers.serialize(
      object.text,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    CheckContentDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CheckContentDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'text':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.text = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CheckContentDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CheckContentDtoBuilder();
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

