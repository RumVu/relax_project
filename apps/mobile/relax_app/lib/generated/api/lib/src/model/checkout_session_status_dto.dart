//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'checkout_session_status_dto.g.dart';

/// CheckoutSessionStatusDto
///
/// Properties:
/// * [status] 
/// * [note] 
/// * [qrCodeUrl] 
/// * [transferContent] 
/// * [bankId] 
/// * [accountNo] 
/// * [accountName] 
/// * [amount] 
/// * [checkoutUrl] 
/// * [checkoutFormfields] 
@BuiltValue()
abstract class CheckoutSessionStatusDto implements Built<CheckoutSessionStatusDto, CheckoutSessionStatusDtoBuilder> {
  @BuiltValueField(wireName: r'status')
  String get status;

  @BuiltValueField(wireName: r'note')
  String get note;

  @BuiltValueField(wireName: r'qrCodeUrl')
  String? get qrCodeUrl;

  @BuiltValueField(wireName: r'transferContent')
  String? get transferContent;

  @BuiltValueField(wireName: r'bankId')
  String? get bankId;

  @BuiltValueField(wireName: r'accountNo')
  String? get accountNo;

  @BuiltValueField(wireName: r'accountName')
  String? get accountName;

  @BuiltValueField(wireName: r'amount')
  num? get amount;

  @BuiltValueField(wireName: r'checkoutUrl')
  String? get checkoutUrl;

  @BuiltValueField(wireName: r'checkoutFormfields')
  JsonObject? get checkoutFormfields;

  CheckoutSessionStatusDto._();

  factory CheckoutSessionStatusDto([void updates(CheckoutSessionStatusDtoBuilder b)]) = _$CheckoutSessionStatusDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CheckoutSessionStatusDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CheckoutSessionStatusDto> get serializer => _$CheckoutSessionStatusDtoSerializer();
}

class _$CheckoutSessionStatusDtoSerializer implements PrimitiveSerializer<CheckoutSessionStatusDto> {
  @override
  final Iterable<Type> types = const [CheckoutSessionStatusDto, _$CheckoutSessionStatusDto];

  @override
  final String wireName = r'CheckoutSessionStatusDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CheckoutSessionStatusDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'status';
    yield serializers.serialize(
      object.status,
      specifiedType: const FullType(String),
    );
    yield r'note';
    yield serializers.serialize(
      object.note,
      specifiedType: const FullType(String),
    );
    if (object.qrCodeUrl != null) {
      yield r'qrCodeUrl';
      yield serializers.serialize(
        object.qrCodeUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.transferContent != null) {
      yield r'transferContent';
      yield serializers.serialize(
        object.transferContent,
        specifiedType: const FullType(String),
      );
    }
    if (object.bankId != null) {
      yield r'bankId';
      yield serializers.serialize(
        object.bankId,
        specifiedType: const FullType(String),
      );
    }
    if (object.accountNo != null) {
      yield r'accountNo';
      yield serializers.serialize(
        object.accountNo,
        specifiedType: const FullType(String),
      );
    }
    if (object.accountName != null) {
      yield r'accountName';
      yield serializers.serialize(
        object.accountName,
        specifiedType: const FullType(String),
      );
    }
    if (object.amount != null) {
      yield r'amount';
      yield serializers.serialize(
        object.amount,
        specifiedType: const FullType(num),
      );
    }
    if (object.checkoutUrl != null) {
      yield r'checkoutUrl';
      yield serializers.serialize(
        object.checkoutUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.checkoutFormfields != null) {
      yield r'checkoutFormfields';
      yield serializers.serialize(
        object.checkoutFormfields,
        specifiedType: const FullType(JsonObject),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CheckoutSessionStatusDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CheckoutSessionStatusDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'status':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.status = valueDes;
          break;
        case r'note':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.note = valueDes;
          break;
        case r'qrCodeUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.qrCodeUrl = valueDes;
          break;
        case r'transferContent':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.transferContent = valueDes;
          break;
        case r'bankId':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.bankId = valueDes;
          break;
        case r'accountNo':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accountNo = valueDes;
          break;
        case r'accountName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.accountName = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.amount = valueDes;
          break;
        case r'checkoutUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.checkoutUrl = valueDes;
          break;
        case r'checkoutFormfields':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(JsonObject),
          ) as JsonObject;
          result.checkoutFormfields = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CheckoutSessionStatusDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CheckoutSessionStatusDtoBuilder();
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

