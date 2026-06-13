//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'rate_content_dto.g.dart';

/// RateContentDto
///
/// Properties:
/// * [contentType] 
/// * [contentId] 
/// * [rating] 
/// * [review] 
@BuiltValue()
abstract class RateContentDto implements Built<RateContentDto, RateContentDtoBuilder> {
  @BuiltValueField(wireName: r'contentType')
  String get contentType;

  @BuiltValueField(wireName: r'contentId')
  String get contentId;

  @BuiltValueField(wireName: r'rating')
  num get rating;

  @BuiltValueField(wireName: r'review')
  String? get review;

  RateContentDto._();

  factory RateContentDto([void updates(RateContentDtoBuilder b)]) = _$RateContentDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RateContentDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RateContentDto> get serializer => _$RateContentDtoSerializer();
}

class _$RateContentDtoSerializer implements PrimitiveSerializer<RateContentDto> {
  @override
  final Iterable<Type> types = const [RateContentDto, _$RateContentDto];

  @override
  final String wireName = r'RateContentDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RateContentDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'contentType';
    yield serializers.serialize(
      object.contentType,
      specifiedType: const FullType(String),
    );
    yield r'contentId';
    yield serializers.serialize(
      object.contentId,
      specifiedType: const FullType(String),
    );
    yield r'rating';
    yield serializers.serialize(
      object.rating,
      specifiedType: const FullType(num),
    );
    if (object.review != null) {
      yield r'review';
      yield serializers.serialize(
        object.review,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RateContentDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RateContentDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'contentType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contentType = valueDes;
          break;
        case r'contentId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.contentId = valueDes;
          break;
        case r'rating':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.rating = valueDes;
          break;
        case r'review':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.review = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RateContentDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RateContentDtoBuilder();
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

