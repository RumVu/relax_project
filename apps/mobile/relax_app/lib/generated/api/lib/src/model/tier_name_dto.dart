//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'tier_name_dto.g.dart';

/// TierNameDto
///
/// Properties:
/// * [name] 
@BuiltValue()
abstract class TierNameDto implements Built<TierNameDto, TierNameDtoBuilder> {
  @BuiltValueField(wireName: r'name')
  String get name;

  TierNameDto._();

  factory TierNameDto([void updates(TierNameDtoBuilder b)]) = _$TierNameDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(TierNameDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<TierNameDto> get serializer => _$TierNameDtoSerializer();
}

class _$TierNameDtoSerializer implements PrimitiveSerializer<TierNameDto> {
  @override
  final Iterable<Type> types = const [TierNameDto, _$TierNameDto];

  @override
  final String wireName = r'TierNameDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    TierNameDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'name';
    yield serializers.serialize(
      object.name,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    TierNameDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required TierNameDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'name':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.name = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  TierNameDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = TierNameDtoBuilder();
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

