//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'feedback_insight_dto.g.dart';

/// FeedbackInsightDto
///
/// Properties:
/// * [useful] - True if the insight was helpful, false otherwise.
@BuiltValue()
abstract class FeedbackInsightDto implements Built<FeedbackInsightDto, FeedbackInsightDtoBuilder> {
  /// True if the insight was helpful, false otherwise.
  @BuiltValueField(wireName: r'useful')
  bool get useful;

  FeedbackInsightDto._();

  factory FeedbackInsightDto([void updates(FeedbackInsightDtoBuilder b)]) = _$FeedbackInsightDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FeedbackInsightDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FeedbackInsightDto> get serializer => _$FeedbackInsightDtoSerializer();
}

class _$FeedbackInsightDtoSerializer implements PrimitiveSerializer<FeedbackInsightDto> {
  @override
  final Iterable<Type> types = const [FeedbackInsightDto, _$FeedbackInsightDto];

  @override
  final String wireName = r'FeedbackInsightDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FeedbackInsightDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'useful';
    yield serializers.serialize(
      object.useful,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    FeedbackInsightDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FeedbackInsightDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'useful':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.useful = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FeedbackInsightDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FeedbackInsightDtoBuilder();
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

