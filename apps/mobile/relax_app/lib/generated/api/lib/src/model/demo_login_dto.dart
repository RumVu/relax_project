//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'demo_login_dto.g.dart';

/// DemoLoginDto
///
/// Properties:
/// * [deviceName] - Optional device name for the session
@BuiltValue()
abstract class DemoLoginDto implements Built<DemoLoginDto, DemoLoginDtoBuilder> {
  /// Optional device name for the session
  @BuiltValueField(wireName: r'deviceName')
  String? get deviceName;

  DemoLoginDto._();

  factory DemoLoginDto([void updates(DemoLoginDtoBuilder b)]) = _$DemoLoginDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DemoLoginDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DemoLoginDto> get serializer => _$DemoLoginDtoSerializer();
}

class _$DemoLoginDtoSerializer implements PrimitiveSerializer<DemoLoginDto> {
  @override
  final Iterable<Type> types = const [DemoLoginDto, _$DemoLoginDto];

  @override
  final String wireName = r'DemoLoginDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DemoLoginDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.deviceName != null) {
      yield r'deviceName';
      yield serializers.serialize(
        object.deviceName,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DemoLoginDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DemoLoginDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'deviceName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.deviceName = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DemoLoginDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DemoLoginDtoBuilder();
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

