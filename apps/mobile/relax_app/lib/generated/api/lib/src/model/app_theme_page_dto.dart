//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:relax_api_client/src/model/app_theme_response_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'app_theme_page_dto.g.dart';

/// AppThemePageDto
///
/// Properties:
/// * [items] 
/// * [total] 
/// * [skip] 
/// * [limit] 
/// * [hasMore] 
@BuiltValue()
abstract class AppThemePageDto implements Built<AppThemePageDto, AppThemePageDtoBuilder> {
  @BuiltValueField(wireName: r'items')
  BuiltList<AppThemeResponseDto> get items;

  @BuiltValueField(wireName: r'total')
  num get total;

  @BuiltValueField(wireName: r'skip')
  num get skip;

  @BuiltValueField(wireName: r'limit')
  num get limit;

  @BuiltValueField(wireName: r'hasMore')
  bool get hasMore;

  AppThemePageDto._();

  factory AppThemePageDto([void updates(AppThemePageDtoBuilder b)]) = _$AppThemePageDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AppThemePageDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AppThemePageDto> get serializer => _$AppThemePageDtoSerializer();
}

class _$AppThemePageDtoSerializer implements PrimitiveSerializer<AppThemePageDto> {
  @override
  final Iterable<Type> types = const [AppThemePageDto, _$AppThemePageDto];

  @override
  final String wireName = r'AppThemePageDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AppThemePageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'items';
    yield serializers.serialize(
      object.items,
      specifiedType: const FullType(BuiltList, [FullType(AppThemeResponseDto)]),
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
    AppThemePageDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AppThemePageDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'items':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(BuiltList, [FullType(AppThemeResponseDto)]),
          ) as BuiltList<AppThemeResponseDto>;
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
  AppThemePageDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AppThemePageDtoBuilder();
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

