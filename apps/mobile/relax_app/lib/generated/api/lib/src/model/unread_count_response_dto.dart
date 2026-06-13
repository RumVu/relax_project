//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'unread_count_response_dto.g.dart';

/// UnreadCountResponseDto
///
/// Properties:
/// * [count] 
@BuiltValue()
abstract class UnreadCountResponseDto implements Built<UnreadCountResponseDto, UnreadCountResponseDtoBuilder> {
  @BuiltValueField(wireName: r'count')
  num get count;

  UnreadCountResponseDto._();

  factory UnreadCountResponseDto([void updates(UnreadCountResponseDtoBuilder b)]) = _$UnreadCountResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UnreadCountResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UnreadCountResponseDto> get serializer => _$UnreadCountResponseDtoSerializer();
}

class _$UnreadCountResponseDtoSerializer implements PrimitiveSerializer<UnreadCountResponseDto> {
  @override
  final Iterable<Type> types = const [UnreadCountResponseDto, _$UnreadCountResponseDto];

  @override
  final String wireName = r'UnreadCountResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UnreadCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'count';
    yield serializers.serialize(
      object.count,
      specifiedType: const FullType(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    UnreadCountResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UnreadCountResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'count':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.count = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UnreadCountResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UnreadCountResponseDtoBuilder();
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

