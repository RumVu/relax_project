//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:relax_api_client/src/model/notification_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'notification_page_dto.g.dart';

/// NotificationPageDto
///
/// Properties:
/// * [items] 
/// * [total] 
/// * [skip] 
/// * [limit] 
/// * [hasMore] 
@BuiltValue()
abstract class NotificationPageDto implements Built<NotificationPageDto, NotificationPageDtoBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<NotificationResponseDto> get items;

  @BuiltValueField(wireName: r'total')
  num get total;

  @BuiltValueField(wireName: r'skip')
  num get skip;

  @BuiltValueField(wireName: r'limit')
  num get limit;

  @BuiltValueField(wireName: r'hasMore')
  bool get hasMore;

  NotificationPageDto._();

  factory NotificationPageDto([void updates(NotificationPageDtoBuilder b)]) = _$NotificationPageDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(NotificationPageDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<NotificationPageDto> get serializer => _$NotificationPageDtoSerializer();
}

class _$NotificationPageDtoSerializer implements PrimitiveSerializer<NotificationPageDto> {
  @override
  final Iterable<Type> types = const [NotificationPageDto, _$NotificationPageDto];

  @override
  final String wireName = r'NotificationPageDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    NotificationPageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(NotificationResponseDto)]),
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
    NotificationPageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required NotificationPageDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(NotificationResponseDto)]),
          ) as BuiltList<NotificationResponseDto>;
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
  NotificationPageDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = NotificationPageDtoBuilder();
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

