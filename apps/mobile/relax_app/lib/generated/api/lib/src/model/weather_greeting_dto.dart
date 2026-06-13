//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'weather_greeting_dto.g.dart';

/// WeatherGreetingDto
///
/// Properties:
/// * [title] 
/// * [subtitle] 
/// * [iconKey] 
@BuiltValue()
abstract class WeatherGreetingDto implements Built<WeatherGreetingDto, WeatherGreetingDtoBuilder> {
  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'subtitle')
  String get subtitle;

  @BuiltValueField(wireName: r'iconKey')
  String get iconKey;

  WeatherGreetingDto._();

  factory WeatherGreetingDto([void updates(WeatherGreetingDtoBuilder b)]) = _$WeatherGreetingDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WeatherGreetingDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WeatherGreetingDto> get serializer => _$WeatherGreetingDtoSerializer();
}

class _$WeatherGreetingDtoSerializer implements PrimitiveSerializer<WeatherGreetingDto> {
  @override
  final Iterable<Type> types = const [WeatherGreetingDto, _$WeatherGreetingDto];

  @override
  final String wireName = r'WeatherGreetingDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WeatherGreetingDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    yield r'subtitle';
    yield serializers.serialize(
      object.subtitle,
      specifiedType: const FullType(String),
    );
    yield r'iconKey';
    yield serializers.serialize(
      object.iconKey,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WeatherGreetingDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WeatherGreetingDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'subtitle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.subtitle = valueDes;
          break;
        case r'iconKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.iconKey = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WeatherGreetingDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WeatherGreetingDtoBuilder();
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

