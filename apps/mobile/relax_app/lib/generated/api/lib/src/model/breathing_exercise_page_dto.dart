//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:relax_api_client/src/model/breathing_exercise_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'breathing_exercise_page_dto.g.dart';

/// BreathingExercisePageDto
///
/// Properties:
/// * [items] 
/// * [total] 
/// * [skip] 
/// * [limit] 
/// * [hasMore] 
@BuiltValue()
abstract class BreathingExercisePageDto implements Built<BreathingExercisePageDto, BreathingExercisePageDtoBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<BreathingExerciseResponseDto> get items;

  @BuiltValueField(wireName: r'total')
  num get total;

  @BuiltValueField(wireName: r'skip')
  num get skip;

  @BuiltValueField(wireName: r'limit')
  num get limit;

  @BuiltValueField(wireName: r'hasMore')
  bool get hasMore;

  BreathingExercisePageDto._();

  factory BreathingExercisePageDto([void updates(BreathingExercisePageDtoBuilder b)]) = _$BreathingExercisePageDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(BreathingExercisePageDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<BreathingExercisePageDto> get serializer => _$BreathingExercisePageDtoSerializer();
}

class _$BreathingExercisePageDtoSerializer implements PrimitiveSerializer<BreathingExercisePageDto> {
  @override
  final Iterable<Type> types = const [BreathingExercisePageDto, _$BreathingExercisePageDto];

  @override
  final String wireName = r'BreathingExercisePageDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    BreathingExercisePageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(BreathingExerciseResponseDto)]),
    );
    yield r'total';
    yield serializers.serialize(
      object.total,
      specifiedType: const FullType(num),
    );
    yield r'skip';
    yield serializers.serialize(
      object.skip,
      specifiedType: const FullType(num),
    );
    yield r'limit';
    yield serializers.serialize(
      object.limit,
      specifiedType: const FullType(num),
    );
    yield r'hasMore';
    yield serializers.serialize(
      object.hasMore,
      specifiedType: const FullType(bool),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    BreathingExercisePageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required BreathingExercisePageDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(BreathingExerciseResponseDto)]),
          ) as BuiltList<BreathingExerciseResponseDto>;
          result.items.replace(valueDes);
          break;
        case r'total':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.total = valueDes;
          break;
        case r'skip':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.skip = valueDes;
          break;
        case r'limit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.limit = valueDes;
          break;
        case r'hasMore':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.hasMore = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  BreathingExercisePageDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = BreathingExercisePageDtoBuilder();
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

