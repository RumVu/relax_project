//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_onboarding_slide_dto.g.dart';

/// CreateOnboardingSlideDto
///
/// Properties:
/// * [title] 
/// * [subtitle] 
/// * [description] 
/// * [imageUrl] 
/// * [animationUrl] 
/// * [displayOrder] 
/// * [isActive] 
@BuiltValue()
abstract class CreateOnboardingSlideDto implements Built<CreateOnboardingSlideDto, CreateOnboardingSlideDtoBuilder> {
  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'subtitle')
  String? get subtitle;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'imageUrl')
  String? get imageUrl;

  @BuiltValueField(wireName: r'animationUrl')
  String? get animationUrl;

  @BuiltValueField(wireName: r'displayOrder')
  num? get displayOrder;

  @BuiltValueField(wireName: r'isActive')
  bool? get isActive;

  CreateOnboardingSlideDto._();

  factory CreateOnboardingSlideDto([void updates(CreateOnboardingSlideDtoBuilder b)]) = _$CreateOnboardingSlideDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateOnboardingSlideDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateOnboardingSlideDto> get serializer => _$CreateOnboardingSlideDtoSerializer();
}

class _$CreateOnboardingSlideDtoSerializer implements PrimitiveSerializer<CreateOnboardingSlideDto> {
  @override
  final Iterable<Type> types = const [CreateOnboardingSlideDto, _$CreateOnboardingSlideDto];

  @override
  final String wireName = r'CreateOnboardingSlideDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateOnboardingSlideDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    if (object.subtitle != null) {
      yield r'subtitle';
      yield serializers.serialize(
        object.subtitle,
        specifiedType: const FullType(String),
      );
    }
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    if (object.imageUrl != null) {
      yield r'imageUrl';
      yield serializers.serialize(
        object.imageUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.animationUrl != null) {
      yield r'animationUrl';
      yield serializers.serialize(
        object.animationUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.displayOrder != null) {
      yield r'displayOrder';
      yield serializers.serialize(
        object.displayOrder,
        specifiedType: const FullType(num),
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
    CreateOnboardingSlideDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateOnboardingSlideDtoBuilder result,
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
        case r'subtitle':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.subtitle = valueDes;
          break;
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'imageUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.imageUrl = valueDes;
          break;
        case r'animationUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.animationUrl = valueDes;
          break;
        case r'displayOrder':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.displayOrder = valueDes;
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
  CreateOnboardingSlideDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateOnboardingSlideDtoBuilder();
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

