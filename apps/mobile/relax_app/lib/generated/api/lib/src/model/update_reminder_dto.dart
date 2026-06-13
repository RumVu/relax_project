//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'update_reminder_dto.g.dart';

/// UpdateReminderDto
///
/// Properties:
/// * [title] 
/// * [message] 
/// * [type] 
/// * [scheduledAt] 
/// * [repeatRule] 
/// * [isActive] 
@BuiltValue()
abstract class UpdateReminderDto implements Built<UpdateReminderDto, UpdateReminderDtoBuilder> {
  @BuiltValueField(wireName: r'title')
  String? get title;

  @BuiltValueField(wireName: r'message')
  String? get message;

  @BuiltValueField(wireName: r'type')
  JsonObject? get type;

  @BuiltValueField(wireName: r'scheduledAt')
  DateTime? get scheduledAt;

  @BuiltValueField(wireName: r'repeatRule')
  String? get repeatRule;

  @BuiltValueField(wireName: r'isActive')
  bool? get isActive;

  UpdateReminderDto._();

  factory UpdateReminderDto([void updates(UpdateReminderDtoBuilder b)]) = _$UpdateReminderDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(UpdateReminderDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<UpdateReminderDto> get serializer => _$UpdateReminderDtoSerializer();
}

class _$UpdateReminderDtoSerializer implements PrimitiveSerializer<UpdateReminderDto> {
  @override
  final Iterable<Type> types = const [UpdateReminderDto, _$UpdateReminderDto];

  @override
  final String wireName = r'UpdateReminderDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    UpdateReminderDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.title != null) {
      yield r'title';
      yield serializers.serialize(
        object.title,
        specifiedType: const FullType(String),
      );
    }
    if (object.message != null) {
      yield r'message';
      yield serializers.serialize(
        object.message,
        specifiedType: const FullType(String),
      );
    }
    if (object.type != null) {
      yield r'type';
      yield serializers.serialize(
        object.type,
        specifiedType: const FullType(JsonObject),
      );
    }
    if (object.scheduledAt != null) {
      yield r'scheduledAt';
      yield serializers.serialize(
        object.scheduledAt,
        specifiedType: const FullType(DateTime),
      );
    }
    if (object.repeatRule != null) {
      yield r'repeatRule';
      yield serializers.serialize(
        object.repeatRule,
        specifiedType: const FullType(String),
      );
    }
    if (object.isActive != null) {
      yield r'isActive';
      yield serializers.serialize(
        object.isActive,
        specifiedType: const FullType(bool),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    UpdateReminderDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required UpdateReminderDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'title':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.title = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'type':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.type = valueDes;
          break;
        case r'scheduledAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.scheduledAt = valueDes;
          break;
        case r'repeatRule':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.repeatRule = valueDes;
          break;
        case r'isActive':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.isActive = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  UpdateReminderDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = UpdateReminderDtoBuilder();
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

