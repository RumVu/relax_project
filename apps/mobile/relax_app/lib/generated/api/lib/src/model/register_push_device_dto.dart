//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'register_push_device_dto.g.dart';

/// RegisterPushDeviceDto
///
/// Properties:
/// * [token] 
/// * [platform] 
/// * [provider] 
/// * [deviceId] 
/// * [deviceName] 
/// * [appVersion] 
/// * [timezone] 
/// * [enabled] 
@BuiltValue()
abstract class RegisterPushDeviceDto implements Built<RegisterPushDeviceDto, RegisterPushDeviceDtoBuilder> {
  @BuiltValueField(wireName: r'token')
  String get token;

  @BuiltValueField(wireName: r'platform')
  JsonObject get platform;

  @BuiltValueField(wireName: r'provider')
  JsonObject? get provider;

  @BuiltValueField(wireName: r'deviceId')
  String? get deviceId;

  @BuiltValueField(wireName: r'deviceName')
  String? get deviceName;

  @BuiltValueField(wireName: r'appVersion')
  String? get appVersion;

  @BuiltValueField(wireName: r'timezone')
  String? get timezone;

  @BuiltValueField(wireName: r'enabled')
  bool? get enabled;

  RegisterPushDeviceDto._();

  factory RegisterPushDeviceDto([void updates(RegisterPushDeviceDtoBuilder b)]) = _$RegisterPushDeviceDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RegisterPushDeviceDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RegisterPushDeviceDto> get serializer => _$RegisterPushDeviceDtoSerializer();
}

class _$RegisterPushDeviceDtoSerializer implements PrimitiveSerializer<RegisterPushDeviceDto> {
  @override
  final Iterable<Type> types = const [RegisterPushDeviceDto, _$RegisterPushDeviceDto];

  @override
  final String wireName = r'RegisterPushDeviceDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RegisterPushDeviceDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'token';
    yield serializers.serialize(
      object.token,
      specifiedType: const FullType(String),
    );
    yield r'platform';
    yield serializers.serialize(
      object.platform,
      specifiedType: const FullType(JsonObject),
    );
    if (object.provider != null) {
      yield r'provider';
      yield serializers.serialize(
        object.provider,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.deviceId != null) {
      yield r'deviceId';
      yield serializers.serialize(
        object.deviceId,
        specifiedType: const FullType(String),
      );
    }
    if (object.deviceName != null) {
      yield r'deviceName';
      yield serializers.serialize(
        object.deviceName,
        specifiedType: const FullType(String),
      );
    }
    if (object.appVersion != null) {
      yield r'appVersion';
      yield serializers.serialize(
        object.appVersion,
        specifiedType: const FullType(String),
      );
    }
    if (object.timezone != null) {
      yield r'timezone';
      yield serializers.serialize(
        object.timezone,
        specifiedType: const FullType(String),
      );
    }
    if (object.enabled != null) {
      yield r'enabled';
      yield serializers.serialize(
        object.enabled,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    RegisterPushDeviceDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RegisterPushDeviceDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'token':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.token = valueDes;
          break;
        case r'platform':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.platform = valueDes;
          break;
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.provider = valueDes;
          break;
        case r'deviceId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceId = valueDes;
          break;
        case r'deviceName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceName = valueDes;
          break;
        case r'appVersion':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.appVersion = valueDes;
          break;
        case r'timezone':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.timezone = valueDes;
          break;
        case r'enabled':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.enabled = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RegisterPushDeviceDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RegisterPushDeviceDtoBuilder();
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

