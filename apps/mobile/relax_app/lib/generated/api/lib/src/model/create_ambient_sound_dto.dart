//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'create_ambient_sound_dto.g.dart';

/// CreateAmbientSoundDto
///
/// Properties:
/// * [title] 
/// * [description] 
/// * [category] 
/// * [soundUrl] 
/// * [imageUrl] 
/// * [duration] 
/// * [isActive] 
@BuiltValue()
abstract class CreateAmbientSoundDto implements Built<CreateAmbientSoundDto, CreateAmbientSoundDtoBuilder> {
  @BuiltValueField(wireName: r'title')
  String get title;

  @BuiltValueField(wireName: r'description')
  String? get description;

  @BuiltValueField(wireName: r'category')
  String get category;

  @BuiltValueField(wireName: r'soundUrl')
  String get soundUrl;

  @BuiltValueField(wireName: r'imageUrl')
  String? get imageUrl;

  @BuiltValueField(wireName: r'duration')
  num? get duration;

  @BuiltValueField(wireName: r'isActive')
  bool? get isActive;

  CreateAmbientSoundDto._();

  factory CreateAmbientSoundDto([void updates(CreateAmbientSoundDtoBuilder b)]) = _$CreateAmbientSoundDto;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(CreateAmbientSoundDtoBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<CreateAmbientSoundDto> get serializer => _$CreateAmbientSoundDtoSerializer();
}

class _$CreateAmbientSoundDtoSerializer implements PrimitiveSerializer<CreateAmbientSoundDto> {
  @override
  final Iterable<Type> types = const [CreateAmbientSoundDto, _$CreateAmbientSoundDto];

  @override
  final String wireName = r'CreateAmbientSoundDto';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    CreateAmbientSoundDto object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'title';
    yield serializers.serialize(
      object.title,
      specifiedType: const FullType(String),
    );
    if (object.description != null) {
      yield r'description';
      yield serializers.serialize(
        object.description,
        specifiedType: const FullType(String),
      );
    }
    yield r'category';
    yield serializers.serialize(
      object.category,
      specifiedType: const FullType(String),
    );
    yield r'soundUrl';
    yield serializers.serialize(
      object.soundUrl,
      specifiedType: const FullType(String),
    );
    if (object.imageUrl != null) {
      yield r'imageUrl';
      yield serializers.serialize(
        object.imageUrl,
        specifiedType: const FullType(String),
      );
    }
    if (object.duration != null) {
      yield r'duration';
      yield serializers.serialize(
        object.duration,
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
    CreateAmbientSoundDto object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required CreateAmbientSoundDtoBuilder result,
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
        case r'description':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.description = valueDes;
          break;
        case r'category':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.category = valueDes;
          break;
        case r'soundUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.soundUrl = valueDes;
          break;
        case r'imageUrl':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.imageUrl = valueDes;
          break;
        case r'duration':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(num),
          ) as num;
          result.duration = valueDes;
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
  CreateAmbientSoundDto deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = CreateAmbientSoundDtoBuilder();
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

