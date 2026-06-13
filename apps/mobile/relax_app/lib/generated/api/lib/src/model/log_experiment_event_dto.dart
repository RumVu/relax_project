//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'log_experiment_event_dto.g.dart';

/// LogExperimentEventDto
///
/// Properties:
/// * [experimentKey] 
/// * [variant] 
/// * [eventType] 
@BuiltValue()
abstract class LogExperimentEventDto implements Built<LogExperimentEventDto, LogExperimentEventDtoBuilder> {
  @BuiltValueField(wireName: r'experimentKey')
  String get experimentKey;

  @BuiltValueField(wireName: r'variant')
  String get variant;

  @BuiltValueField(wireName: r'eventType')
  LogExperimentEventDtoEventTypeEnum get eventType;
  // enum eventTypeEnum {  viewed,  converted,  };

  LogExperimentEventDto._();

  factory LogExperimentEventDto([void updates(LogExperimentEventDtoBuilder b)]) = _$LogExperimentEventDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(LogExperimentEventDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<LogExperimentEventDto> get serializer => _$LogExperimentEventDtoSerializer();
}

class _$LogExperimentEventDtoSerializer implements PrimitiveSerializer<LogExperimentEventDto> {
  @override
  final Iterable<Type> types = const [LogExperimentEventDto, _$LogExperimentEventDto];

  @override
  final String wireName = r'LogExperimentEventDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    LogExperimentEventDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'experimentKey';
    yield serializers.serialize(
      object.experimentKey,
      specifiedType: const FullType(String),
    );
    yield r'variant';
    yield serializers.serialize(
      object.variant,
      specifiedType: const FullType(String),
    );
    yield r'eventType';
    yield serializers.serialize(
      object.eventType,
      specifiedType: const FullType(LogExperimentEventDtoEventTypeEnum),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    LogExperimentEventDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required LogExperimentEventDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'experimentKey':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.experimentKey = valueDes;
          break;
        case r'variant':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.variant = valueDes;
          break;
        case r'eventType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(LogExperimentEventDtoEventTypeEnum),
          ) as LogExperimentEventDtoEventTypeEnum;
          result.eventType = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  LogExperimentEventDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = LogExperimentEventDtoBuilder();
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

class LogExperimentEventDtoEventTypeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'viewed')
  static const LogExperimentEventDtoEventTypeEnum viewed = _$logExperimentEventDtoEventTypeEnum_viewed;
  @BuiltValueEnumConst(wireName: r'converted')
  static const LogExperimentEventDtoEventTypeEnum converted = _$logExperimentEventDtoEventTypeEnum_converted;

  static Serializer<LogExperimentEventDtoEventTypeEnum> get serializer => _$logExperimentEventDtoEventTypeEnumSerializer;

  const LogExperimentEventDtoEventTypeEnum._(String name): super(name);

  static BuiltSet<LogExperimentEventDtoEventTypeEnum> get values => _$logExperimentEventDtoEventTypeEnumValues;
  static LogExperimentEventDtoEventTypeEnum valueOf(String name) => _$logExperimentEventDtoEventTypeEnumValueOf(name);
}

