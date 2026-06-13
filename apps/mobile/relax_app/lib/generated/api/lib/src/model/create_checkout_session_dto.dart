//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_checkout_session_dto.g.dart';

/// CreateCheckoutSessionDto
///
/// Properties:
/// * [planName] 
/// * [amount] - Deprecated compatibility field. The backend always prices from SubscriptionTier/fallback plan catalog and ignores client-provided amount.
/// * [currency] - Deprecated compatibility field. The backend always uses the server-side plan currency.
/// * [provider] 
/// * [description] 
/// * [successUrl] 
/// * [errorUrl] 
/// * [cancelUrl] 
@BuiltValue()
abstract class CreateCheckoutSessionDto implements Built<CreateCheckoutSessionDto, CreateCheckoutSessionDtoBuilder> {
  @BuiltValueField(wireName: r'planName')
  String get planName;

  /// Deprecated compatibility field. The backend always prices from SubscriptionTier/fallback plan catalog and ignores client-provided amount.
  @BuiltValueField(wireName: r'amount')
  num? get amount;

  /// Deprecated compatibility field. The backend always uses the server-side plan currency.
  @BuiltValueField(wireName: r'currency')
  String? get currency;

  @BuiltValueField(wireName: r'provider')
  CreateCheckoutSessionDtoProviderEnum? get provider;
  // enum providerEnum {  STRIPE,  APP_STORE,  GOOGLE_PLAY,  MANUAL,  SEPAY,  };

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'successUrl')
  String? get successUrl;

  @BuiltValueField(wireName: r'errorUrl')
  String? get errorUrl;

  @BuiltValueField(wireName: r'cancelUrl')
  String? get cancelUrl;

  CreateCheckoutSessionDto._();

  factory CreateCheckoutSessionDto([void updates(CreateCheckoutSessionDtoBuilder b)]) = _$CreateCheckoutSessionDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateCheckoutSessionDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateCheckoutSessionDto> get serializer => _$CreateCheckoutSessionDtoSerializer();
}

class _$CreateCheckoutSessionDtoSerializer implements PrimitiveSerializer<CreateCheckoutSessionDto> {
  @override
  final Iterable<Type> types = const [CreateCheckoutSessionDto, _$CreateCheckoutSessionDto];

  @override
  final String wireName = r'CreateCheckoutSessionDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateCheckoutSessionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'planName';
    yield serializers.serialize(
      object.planName,
      specifiedType: const FullType(String),
    );
    if (object.amount != null) {
      yield r'amount';
      yield serializers.serialize(
        object.amount,
        specifiedType: const FullType(num),
      );
    }
    if (object.currency != null) {
      yield r'currency';
      yield serializers.serialize(
        object.currency,
        specifiedType: const FullType(String),
      );
    }
    if (object.provider != null) {
      yield r'provider';
      yield serializers.serialize(
        object.provider,
        specifiedType: const FullType(CreateCheckoutSessionDtoProviderEnum),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    if (object.successUrl != null) {
      yield r'successUrl';
      yield serializers.serialize(
        object.successUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.errorUrl != null) {
      yield r'errorUrl';
      yield serializers.serialize(
        object.errorUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.cancelUrl != null) {
      yield r'cancelUrl';
      yield serializers.serialize(
        object.cancelUrl,
        specifiedType: const FullType(String),
      );
    }
  }

  @override
  Object serialize(
    Serializers serializers,
    CreateCheckoutSessionDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateCheckoutSessionDtoBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'planName':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.planName = valueDes;
          break;
        case r'amount':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.amount = valueDes;
          break;
        case r'currency':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.currency = valueDes;
          break;
        case r'provider':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(CreateCheckoutSessionDtoProviderEnum),
          ) as CreateCheckoutSessionDtoProviderEnum;
          result.provider = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'successUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.successUrl = valueDes;
          break;
        case r'errorUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.errorUrl = valueDes;
          break;
        case r'cancelUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.cancelUrl = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  CreateCheckoutSessionDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateCheckoutSessionDtoBuilder();
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

class CreateCheckoutSessionDtoProviderEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'STRIPE')
  static const CreateCheckoutSessionDtoProviderEnum STRIPE = _$createCheckoutSessionDtoProviderEnum_STRIPE;
  @BuiltValueEnumConst(wireName: r'APP_STORE')
  static const CreateCheckoutSessionDtoProviderEnum APP_STORE = _$createCheckoutSessionDtoProviderEnum_APP_STORE;
  @BuiltValueEnumConst(wireName: r'GOOGLE_PLAY')
  static const CreateCheckoutSessionDtoProviderEnum GOOGLE_PLAY = _$createCheckoutSessionDtoProviderEnum_GOOGLE_PLAY;
  @BuiltValueEnumConst(wireName: r'MANUAL')
  static const CreateCheckoutSessionDtoProviderEnum MANUAL = _$createCheckoutSessionDtoProviderEnum_MANUAL;
  @BuiltValueEnumConst(wireName: r'SEPAY')
  static const CreateCheckoutSessionDtoProviderEnum SEPAY = _$createCheckoutSessionDtoProviderEnum_SEPAY;

  static Serializer<CreateCheckoutSessionDtoProviderEnum> get serializer => _$createCheckoutSessionDtoProviderEnumSerializer;

  const CreateCheckoutSessionDtoProviderEnum._(String name): super(name);

  static BuiltSet<CreateCheckoutSessionDtoProviderEnum> get values => _$createCheckoutSessionDtoProviderEnumValues;
  static CreateCheckoutSessionDtoProviderEnum valueOf(String name) => _$createCheckoutSessionDtoProviderEnumValueOf(name);
}

