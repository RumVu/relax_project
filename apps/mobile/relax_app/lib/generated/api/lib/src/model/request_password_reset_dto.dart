//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'request_password_reset_dto.g.dart';

/// RequestPasswordResetDto
///
/// Properties:
/// * [email] 
@BuiltValue()
abstract class RequestPasswordResetDto implements Built<RequestPasswordResetDto, RequestPasswordResetDtoBuilder> {
  @BuiltValueField(wireName: r'email')
  String get email;

  RequestPasswordResetDto._();

  factory RequestPasswordResetDto([void updates(RequestPasswordResetDtoBuilder b)]) = _$RequestPasswordResetDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(RequestPasswordResetDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<RequestPasswordResetDto> get serializer => _$RequestPasswordResetDtoSerializer();
}

class _$RequestPasswordResetDtoSerializer implements PrimitiveSerializer<RequestPasswordResetDto> {
  @override
  final Iterable<Type> types = const [RequestPasswordResetDto, _$RequestPasswordResetDto];

  @override
  final String wireName = r'RequestPasswordResetDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    RequestPasswordResetDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'email';
    yield serializers.serialize(
      object.email,
      specifiedType: const FullType(String),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    RequestPasswordResetDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required RequestPasswordResetDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'email':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.email = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  RequestPasswordResetDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = RequestPasswordResetDtoBuilder();
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

