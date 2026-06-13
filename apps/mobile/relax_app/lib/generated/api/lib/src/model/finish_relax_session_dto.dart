//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'finish_relax_session_dto.g.dart';

/// FinishRelaxSessionDto
///
/// Properties:
/// * [moodAfter] 
/// * [reliefLevel] 
/// * [note] 
/// * [nextActionAccepted] 
@BuiltValue()
abstract class FinishRelaxSessionDto implements Built<FinishRelaxSessionDto, FinishRelaxSessionDtoBuilder> {
  @BuiltValueField(wireName: r'moodAfter')
  JsonObject? get moodAfter;

  @BuiltValueField(wireName: r'reliefLevel')
  num? get reliefLevel;

  @BuiltValueField(wireName: r'note')
  String? get note;

  @BuiltValueField(wireName: r'nextActionAccepted')
  String? get nextActionAccepted;

  FinishRelaxSessionDto._();

  factory FinishRelaxSessionDto([void updates(FinishRelaxSessionDtoBuilder b)]) = _$FinishRelaxSessionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(FinishRelaxSessionDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<FinishRelaxSessionDto> get serializer => _$FinishRelaxSessionDtoSerializer();
}

class _$FinishRelaxSessionDtoSerializer implements PrimitiveSerializer<FinishRelaxSessionDto> {
  @override
  final Iterable<Type> types = const [FinishRelaxSessionDto, _$FinishRelaxSessionDto];

  @override
  final String wireName = r'FinishRelaxSessionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    FinishRelaxSessionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.moodAfter != null) {
      yield r'moodAfter';
      yield serializers.serialize(
        object.moodAfter,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.reliefLevel != null) {
      yield r'reliefLevel';
      yield serializers.serialize(
        object.reliefLevel,
        specifiedType: const FullType(num),
      );
    }
    if (object.note != null) {
      yield r'note';
      yield serializers.serialize(
        object.note,
        specifiedType: const FullType(String),
      );
    }
    if (object.nextActionAccepted != null) {
      yield r'nextActionAccepted';
      yield serializers.serialize(
        object.nextActionAccepted,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    FinishRelaxSessionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required FinishRelaxSessionDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'moodAfter':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.moodAfter = valueDes;
          break;
        case r'reliefLevel':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.reliefLevel = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        case r'nextActionAccepted':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.nextActionAccepted = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  FinishRelaxSessionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = FinishRelaxSessionDtoBuilder();
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

