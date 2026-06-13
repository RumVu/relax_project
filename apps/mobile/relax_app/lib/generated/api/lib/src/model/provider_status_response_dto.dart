//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'provider_status_response_dto.g.dart';

/// ProviderStatusResponseDto
///
/// Properties:
/// * [configured] 
/// * [providers] 
@BuiltValue()
abstract class ProviderStatusResponseDto implements Built<ProviderStatusResponseDto, ProviderStatusResponseDtoBuilder> {
  @BuiltValueField(wireName: r'configured')
  bool get configured;

  @BuiltValueField(wireName: r'providers')
  JsonObject get providers;

  ProviderStatusResponseDto._();

  factory ProviderStatusResponseDto([void updates(ProviderStatusResponseDtoBuilder b)]) = _$ProviderStatusResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ProviderStatusResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ProviderStatusResponseDto> get serializer => _$ProviderStatusResponseDtoSerializer();
}

class _$ProviderStatusResponseDtoSerializer implements PrimitiveSerializer<ProviderStatusResponseDto> {
  @override
  final Iterable<Type> types = const [ProviderStatusResponseDto, _$ProviderStatusResponseDto];

  @override
  final String wireName = r'ProviderStatusResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ProviderStatusResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'configured';
    yield serializers.serialize(
      object.configured,
      specifiedType: const FullType(bool),
    );
    yield r'providers';
    yield serializers.serialize(
      object.providers,
      specifiedType: const FullType(JsonObject),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ProviderStatusResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ProviderStatusResponseDtoBuilder result,
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
        case r'providers':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.providers = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ProviderStatusResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ProviderStatusResponseDtoBuilder();
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

