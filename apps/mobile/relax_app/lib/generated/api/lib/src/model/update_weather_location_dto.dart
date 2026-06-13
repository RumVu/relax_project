//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_weather_location_dto.g.dart';

/// UpdateWeatherLocationDto
///
/// Properties:
/// * [latitude] 
/// * [longitude] 
/// * [timezone] 
/// * [locationName] 
/// * [weatherEnabled] 
/// * [reverseGeocode] 
/// * [localityLanguage] 
@BuiltValue()
abstract class UpdateWeatherLocationDto implements Built<UpdateWeatherLocationDto, UpdateWeatherLocationDtoBuilder> {
  @BuiltValueField(wireName: r'latitude')
  num? get latitude;

  @BuiltValueField(wireName: r'longitude')
  num? get longitude;

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'locationName')
  String? get locationName;

  @BuiltValueField(wireName: r'weatherEnabled')
  bool? get weatherEnabled;

  @BuiltValueField(wireName: r'reverseGeocode')
  bool? get reverseGeocode;

  @BuiltValueField(wireName: r'localityLanguage')
  String? get localityLanguage;

  UpdateWeatherLocationDto._();

  factory UpdateWeatherLocationDto([void updates(UpdateWeatherLocationDtoBuilder b)]) = _$UpdateWeatherLocationDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateWeatherLocationDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateWeatherLocationDto> get serializer => _$UpdateWeatherLocationDtoSerializer();
}

class _$UpdateWeatherLocationDtoSerializer implements PrimitiveSerializer<UpdateWeatherLocationDto> {
  @override
  final Iterable<Type> types = const [UpdateWeatherLocationDto, _$UpdateWeatherLocationDto];

  @override
  final String wireName = r'UpdateWeatherLocationDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateWeatherLocationDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.latitude != null) {
      yield r'latitude';
      yield serializers.serialize(
        object.latitude,
        specifiedType: const FullType(num),
      );
    }
    if (object.longitude != null) {
      yield r'longitude';
      yield serializers.serialize(
        object.longitude,
        specifiedType: const FullType(num),
      );
    }
    if (object.timezone != null) {
      yield r'timezone';
      yield serializers.serialize(
        object.timezone,
        specifiedType: const FullType(String),
      );
    }
    if (object.locationName != null) {
      yield r'locationName';
      yield serializers.serialize(
        object.locationName,
        specifiedType: const FullType(String),
      );
    }
    if (object.weatherEnabled != null) {
      yield r'weatherEnabled';
      yield serializers.serialize(
        object.weatherEnabled,
        specifiedType: const FullType(bool),
      );
    }
    if (object.reverseGeocode != null) {
      yield r'reverseGeocode';
      yield serializers.serialize(
        object.reverseGeocode,
        specifiedType: const FullType(bool),
      );
    }
    if (object.localityLanguage != null) {
      yield r'localityLanguage';
      yield serializers.serialize(
        object.localityLanguage,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateWeatherLocationDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateWeatherLocationDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'latitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.latitude = valueDes;
          break;
        case r'longitude':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.longitude = valueDes;
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.timezone = valueDes;
          break;
        case r'locationName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.locationName = valueDes;
          break;
        case r'weatherEnabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.weatherEnabled = valueDes;
          break;
        case r'reverseGeocode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.reverseGeocode = valueDes;
          break;
        case r'localityLanguage':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.localityLanguage = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateWeatherLocationDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateWeatherLocationDtoBuilder();
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

