//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:relax_api_client/src/model/mood_checkin_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'mood_checkin_page_dto.g.dart';

/// MoodCheckinPageDto
///
/// Properties:
/// * [items] 
/// * [total] 
/// * [skip] 
/// * [limit] 
/// * [hasMore] 
@BuiltValue()
abstract class MoodCheckinPageDto implements Built<MoodCheckinPageDto, MoodCheckinPageDtoBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<MoodCheckinResponseDto> get items;

  @BuiltValueField(wireName: r'total')
  num get total;

  @BuiltValueField(wireName: r'skip')
  num get skip;

  @BuiltValueField(wireName: r'limit')
  num get limit;

  @BuiltValueField(wireName: r'hasMore')
  bool get hasMore;

  MoodCheckinPageDto._();

  factory MoodCheckinPageDto([void updates(MoodCheckinPageDtoBuilder b)]) = _$MoodCheckinPageDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(MoodCheckinPageDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<MoodCheckinPageDto> get serializer => _$MoodCheckinPageDtoSerializer();
}

class _$MoodCheckinPageDtoSerializer implements PrimitiveSerializer<MoodCheckinPageDto> {
  @override
  final Iterable<Type> types = const [MoodCheckinPageDto, _$MoodCheckinPageDto];

  @override
  final String wireName = r'MoodCheckinPageDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    MoodCheckinPageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(MoodCheckinResponseDto)]),
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
    MoodCheckinPageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required MoodCheckinPageDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(MoodCheckinResponseDto)]),
          ) as BuiltList<MoodCheckinResponseDto>;
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
  MoodCheckinPageDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = MoodCheckinPageDtoBuilder();
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

