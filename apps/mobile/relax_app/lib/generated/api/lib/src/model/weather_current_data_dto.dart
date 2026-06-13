//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'weather_current_data_dto.g.dart';

/// WeatherCurrentDataDto
///
/// Properties:
/// * [temperature] 
/// * [temperatureUnit] 
/// * [weatherCode] 
/// * [isDay] 
/// * [observedAt] 
@BuiltValue()
abstract class WeatherCurrentDataDto implements Built<WeatherCurrentDataDto, WeatherCurrentDataDtoBuilder> {
  @BuiltValueField(wireName: r'temperature')
  num? get temperature;

  @BuiltValueField(wireName: r'temperatureUnit')
  String get temperatureUnit;

  @BuiltValueField(wireName: r'weatherCode')
  num? get weatherCode;

  @BuiltValueField(wireName: r'isDay')
  bool get isDay;

  @BuiltValueField(wireName: r'observedAt')
  String? get observedAt;

  WeatherCurrentDataDto._();

  factory WeatherCurrentDataDto([void updates(WeatherCurrentDataDtoBuilder b)]) = _$WeatherCurrentDataDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WeatherCurrentDataDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WeatherCurrentDataDto> get serializer => _$WeatherCurrentDataDtoSerializer();
}

class _$WeatherCurrentDataDtoSerializer implements PrimitiveSerializer<WeatherCurrentDataDto> {
  @override
  final Iterable<Type> types = const [WeatherCurrentDataDto, _$WeatherCurrentDataDto];

  @override
  final String wireName = r'WeatherCurrentDataDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WeatherCurrentDataDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'temperature';
    yield object.temperature == null ? null : serializers.serialize(
      object.temperature,
      specifiedType: const FullType.nullable(num),
    );
    yield r'temperatureUnit';
    yield serializers.serialize(
      object.temperatureUnit,
      specifiedType: const FullType(String),
    );
    yield r'weatherCode';
    yield object.weatherCode == null ? null : serializers.serialize(
      object.weatherCode,
      specifiedType: const FullType.nullable(num),
    );
    yield r'isDay';
    yield serializers.serialize(
      object.isDay,
      specifiedType: const FullType(bool),
    );
    yield r'observedAt';
    yield object.observedAt == null ? null : serializers.serialize(
      object.observedAt,
      specifiedType: const FullType.nullable(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WeatherCurrentDataDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WeatherCurrentDataDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'temperature':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.temperature = valueDes;
          break;
        case r'temperatureUnit':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.temperatureUnit = valueDes;
          break;
        case r'weatherCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.weatherCode = valueDes;
          break;
        case r'isDay':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isDay = valueDes;
          break;
        case r'observedAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.observedAt = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WeatherCurrentDataDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WeatherCurrentDataDtoBuilder();
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

