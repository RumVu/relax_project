//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:relax_api_client/src/model/weather_current_data_dto.dart';
import 'package:relax_api_client/src/model/weather_greeting_dto.dart';
import 'package:relax_api_client/src/model/weather_location_dto.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'weather_current_response_dto.g.dart';

/// WeatherCurrentResponseDto
///
/// Properties:
/// * [configured] 
/// * [reason] 
/// * [greeting] 
/// * [provider] 
/// * [location] 
/// * [reverseGeocode] 
/// * [current] 
@BuiltValue()
abstract class WeatherCurrentResponseDto implements Built<WeatherCurrentResponseDto, WeatherCurrentResponseDtoBuilder> {
  @BuiltValueField(wireName: r'configured')
  bool get configured;

  @BuiltValueField(wireName: r'reason')
  String? get reason;

  @BuiltValueField(wireName: r'greeting')
  WeatherGreetingDto? get greeting;

  @BuiltValueField(wireName: r'provider')
  String? get provider;

  @BuiltValueField(wireName: r'location')
  WeatherLocationDto? get location;

  @BuiltValueField(wireName: r'reverseGeocode')
  JsonObject? get reverseGeocode;

  @BuiltValueField(wireName: r'current')
  WeatherCurrentDataDto? get current;

  WeatherCurrentResponseDto._();

  factory WeatherCurrentResponseDto([void updates(WeatherCurrentResponseDtoBuilder b)]) = _$WeatherCurrentResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(WeatherCurrentResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<WeatherCurrentResponseDto> get serializer => _$WeatherCurrentResponseDtoSerializer();
}

class _$WeatherCurrentResponseDtoSerializer implements PrimitiveSerializer<WeatherCurrentResponseDto> {
  @override
  final Iterable<Type> types = const [WeatherCurrentResponseDto, _$WeatherCurrentResponseDto];

  @override
  final String wireName = r'WeatherCurrentResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    WeatherCurrentResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'configured';
    yield serializers.serialize(
      object.configured,
      specifiedType: const FullType(bool),
    );
    if (object.reason != null) {
      yield r'reason';
      yield serializers.serialize(
        object.reason,
        specifiedType: const FullType(String),
      );
    }
    if (object.greeting != null) {
      yield r'greeting';
      yield serializers.serialize(
        object.greeting,
        specifiedType: const FullType(WeatherGreetingDto),
      );
    }
    if (object.provider != null) {
      yield r'provider';
      yield serializers.serialize(
        object.provider,
        specifiedType: const FullType(String),
      );
    }
    if (object.location != null) {
      yield r'location';
      yield serializers.serialize(
        object.location,
        specifiedType: const FullType(WeatherLocationDto),
      );
    }
    if (object.reverseGeocode != null) {
      yield r'reverseGeocode';
      yield serializers.serialize(
        object.reverseGeocode,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
    if (object.current != null) {
      yield r'current';
      yield serializers.serialize(
        object.current,
        specifiedType: const FullType(WeatherCurrentDataDto),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    WeatherCurrentResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required WeatherCurrentResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'configured':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.configured = valueDes;
          break;
        case r'reason':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.reason = valueDes;
          break;
        case r'greeting':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WeatherGreetingDto),
          ) as WeatherGreetingDto;
          result.greeting.replace(valueDes);
          break;
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.provider = valueDes;
          break;
        case r'location':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WeatherLocationDto),
          ) as WeatherLocationDto;
          result.location.replace(valueDes);
          break;
        case r'reverseGeocode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.reverseGeocode = valueDes;
          break;
        case r'current':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(WeatherCurrentDataDto),
          ) as WeatherCurrentDataDto;
          result.current.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  WeatherCurrentResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = WeatherCurrentResponseDtoBuilder();
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

