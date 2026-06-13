//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'weather_forecast_day_dto.g.dart';

/// WeatherForecastDayDto
///
/// Properties:
/// * [date] 
/// * [temperatureMax] 
/// * [temperatureMin] 
/// * [precipitationProbability] 
/// * [weatherCode] 
@BuiltValue()
abstract class WeatherForecastDayDto implements Built<WeatherForecastDayDto, WeatherForecastDayDtoBuilder> {
  @BuiltValueField(wireName: r'date')
  String get date;

  @BuiltValueField(wireName: r'temperatureMax')
  num? get temperatureMax;

  @BuiltValueField(wireName: r'temperatureMin')
  num? get temperatureMin;

  @BuiltValueField(wireName: r'precipitationProbability')
  num? get precipitationProbability;

  @BuiltValueField(wireName: r'weatherCode')
  num? get weatherCode;

  WeatherForecastDayDto._();

  factory WeatherForecastDayDto([void updates(WeatherForecastDayDtoBuilder b)]) = _$WeatherForecastDayDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WeatherForecastDayDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WeatherForecastDayDto> get serializer => _$WeatherForecastDayDtoSerializer();
}

class _$WeatherForecastDayDtoSerializer implements PrimitiveSerializer<WeatherForecastDayDto> {
  @override
  final Iterable<Type> types = const [WeatherForecastDayDto, _$WeatherForecastDayDto];

  @override
  final String wireName = r'WeatherForecastDayDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WeatherForecastDayDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'date';
    yield serializers.serialize(
      object.date,
      specifiedType: const FullType(String),
    );
    yield r'temperatureMax';
    yield object.temperatureMax == null ? null : serializers.serialize(
      object.temperatureMax,
      specifiedType: const FullType.nullable(num),
    );
    yield r'temperatureMin';
    yield object.temperatureMin == null ? null : serializers.serialize(
      object.temperatureMin,
      specifiedType: const FullType.nullable(num),
    );
    yield r'precipitationProbability';
    yield object.precipitationProbability == null ? null : serializers.serialize(
      object.precipitationProbability,
      specifiedType: const FullType.nullable(num),
    );
    yield r'weatherCode';
    yield object.weatherCode == null ? null : serializers.serialize(
      object.weatherCode,
      specifiedType: const FullType.nullable(num),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    WeatherForecastDayDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WeatherForecastDayDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'date':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.date = valueDes;
          break;
        case r'temperatureMax':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.temperatureMax = valueDes;
          break;
        case r'temperatureMin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.temperatureMin = valueDes;
          break;
        case r'precipitationProbability':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.precipitationProbability = valueDes;
          break;
        case r'weatherCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(num),
          ) as num?;
          if (valueDes == null) continue;
          result.weatherCode = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WeatherForecastDayDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WeatherForecastDayDtoBuilder();
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

