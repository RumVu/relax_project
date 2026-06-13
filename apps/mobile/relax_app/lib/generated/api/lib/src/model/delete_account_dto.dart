//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'delete_account_dto.g.dart';

/// DeleteAccountDto
///
/// Properties:
/// * [mode] 
/// * [password] 
@BuiltValue()
abstract class DeleteAccountDto implements Built<DeleteAccountDto, DeleteAccountDtoBuilder> {
  @BuiltValueField(wireName: r'mode')
  DeleteAccountDtoModeEnum? get mode;
  // enum modeEnum {  SOFT,  HARD,  };

  @BuiltValueField(wireName: r'password')
  String? get password;

  DeleteAccountDto._();

  factory DeleteAccountDto([void updates(DeleteAccountDtoBuilder b)]) = _$DeleteAccountDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(DeleteAccountDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<DeleteAccountDto> get serializer => _$DeleteAccountDtoSerializer();
}

class _$DeleteAccountDtoSerializer implements PrimitiveSerializer<DeleteAccountDto> {
  @override
  final Iterable<Type> types = const [DeleteAccountDto, _$DeleteAccountDto];

  @override
  final String wireName = r'DeleteAccountDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    DeleteAccountDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    if (object.mode != null) {
      yield r'mode';
      yield serializers.serialize(
        object.mode,
        specifiedType: const FullType(DeleteAccountDtoModeEnum),
      );
    }
    if (object.password != null) {
      yield r'password';
      yield serializers.serialize(
        object.password,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    DeleteAccountDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required DeleteAccountDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'mode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DeleteAccountDtoModeEnum),
          ) as DeleteAccountDtoModeEnum;
          result.mode = valueDes;
          break;
        case r'password':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.password = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  DeleteAccountDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = DeleteAccountDtoBuilder();
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

class DeleteAccountDtoModeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'SOFT')
  static const DeleteAccountDtoModeEnum SOFT = _$deleteAccountDtoModeEnum_SOFT;
  @BuiltValueEnumConst(wireName: r'HARD')
  static const DeleteAccountDtoModeEnum HARD = _$deleteAccountDtoModeEnum_HARD;

  static Serializer<DeleteAccountDtoModeEnum> get serializer => _$deleteAccountDtoModeEnumSerializer;

  const DeleteAccountDtoModeEnum._(String name): super(name);

  static BuiltSet<DeleteAccountDtoModeEnum> get values => _$deleteAccountDtoModeEnumValues;
  static DeleteAccountDtoModeEnum valueOf(String name) => _$deleteAccountDtoModeEnumValueOf(name);
}

