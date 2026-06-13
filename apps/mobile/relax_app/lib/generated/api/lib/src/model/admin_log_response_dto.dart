//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:relax_api_client/src/model/admin_log_actor_dto.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'admin_log_response_dto.g.dart';

/// AdminLogResponseDto
///
/// Properties:
/// * [id] 
/// * [adminId] 
/// * [action] 
/// * [targetId] 
/// * [targetType] 
/// * [details] 
/// * [createdAt] 
/// * [admin] 
@BuiltValue()
abstract class AdminLogResponseDto implements Built<AdminLogResponseDto, AdminLogResponseDtoBuilder> {
  @BuiltValueField(wireName: r'id')
  String get id;

  @BuiltValueField(wireName: r'adminId')
  String get adminId;

  @BuiltValueField(wireName: r'action')
  String get action;

  @BuiltValueField(wireName: r'targetId')
  String? get targetId;

  @BuiltValueField(wireName: r'targetType')
  String? get targetType;

  @BuiltValueField(wireName: r'details')
  String get details;

  @BuiltValueField(wireName: r'createdAt')
  DateTime get createdAt;

  @BuiltValueField(wireName: r'admin')
  AdminLogActorDto? get admin;

  AdminLogResponseDto._();

  factory AdminLogResponseDto([void updates(AdminLogResponseDtoBuilder b)]) = _$AdminLogResponseDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(AdminLogResponseDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<AdminLogResponseDto> get serializer => _$AdminLogResponseDtoSerializer();
}

class _$AdminLogResponseDtoSerializer implements PrimitiveSerializer<AdminLogResponseDto> {
  @override
  final Iterable<Type> types = const [AdminLogResponseDto, _$AdminLogResponseDto];

  @override
  final String wireName = r'AdminLogResponseDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    AdminLogResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'id';
    yield serializers.serialize(
      object.id,
      specifiedType: const FullType(String),
    );
    yield r'adminId';
    yield serializers.serialize(
      object.adminId,
      specifiedType: const FullType(String),
    );
    yield r'action';
    yield serializers.serialize(
      object.action,
      specifiedType: const FullType(String),
    );
    yield r'targetId';
    yield object.targetId == null ? null : serializers.serialize(
      object.targetId,
      specifiedType: const FullType.nullable(String),
    );
    yield r'targetType';
    yield object.targetType == null ? null : serializers.serialize(
      object.targetType,
      specifiedType: const FullType.nullable(String),
    );
    yield r'details';
    yield serializers.serialize(
      object.details,
      specifiedType: const FullType(String),
    );
    yield r'createdAt';
    yield serializers.serialize(
      object.createdAt,
      specifiedType: const FullType(DateTime),
    );
    if (object.admin != null) {
      yield r'admin';
      yield serializers.serialize(
        object.admin,
        specifiedType: const FullType(AdminLogActorDto),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    AdminLogResponseDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required AdminLogResponseDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'id':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.id = valueDes;
          break;
        case r'adminId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.adminId = valueDes;
          break;
        case r'action':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.action = valueDes;
          break;
        case r'targetId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.targetId = valueDes;
          break;
        case r'targetType':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(String),
          ) as String?;
          if (valueDes == null) continue;
          result.targetType = valueDes;
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.details = valueDes;
          break;
        case r'createdAt':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.createdAt = valueDes;
          break;
        case r'admin':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(AdminLogActorDto),
          ) as AdminLogActorDto;
          result.admin.replace(valueDes);
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  AdminLogResponseDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = AdminLogResponseDtoBuilder();
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

