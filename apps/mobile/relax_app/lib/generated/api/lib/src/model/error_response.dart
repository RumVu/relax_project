//
// AUTO-GENERATED FILE, DO NOT MODIFY!
//

// ignore_for_file: unused_element
import 'package:built_collection/built_collection.dart';
import 'package:built_value/json_object.dart';
import 'package:built_value/built_value.dart';
import 'package:built_value/serializer.dart';

part 'error_response.g.dart';

/// ErrorResponse
///
/// Properties:
/// * [success] 
/// * [statusCode] 
/// * [code] 
/// * [message] 
/// * [details] - Optional validation messages, Prisma metadata, or provider details.
/// * [path] 
/// * [timestamp] 
@BuiltValue()
abstract class ErrorResponse implements Built<ErrorResponse, ErrorResponseBuilder> {
  @BuiltValueField(wireName: r'success')
  bool get success;

  @BuiltValueField(wireName: r'statusCode')
  int get statusCode;

  @BuiltValueField(wireName: r'code')
  ErrorResponseCodeEnum get code;
  // enum codeEnum {  VALIDATION_FAILED,  ROUTE_NOT_FOUND,  RATE_LIMIT_EXCEEDED,  INTERNAL_SERVER_ERROR,  CONFIG_MISSING_REQUIRED_ENV,  STORAGE_NOT_CONFIGURED,  STORAGE_INVALID_PATH,  STORAGE_OPERATION_FAILED,  DATABASE_UNIQUE_CONSTRAINT,  DATABASE_FOREIGN_KEY_CONSTRAINT,  DATABASE_RECORD_NOT_FOUND,  AUTH_INVALID_CREDENTIALS,  AUTH_INACTIVE_USER,  AUTH_REFRESH_TOKEN_INVALID,  AUTH_TOKEN_INVALID,  AUTH_TOKEN_EXPIRED,  AUTH_TOKEN_CONSUMED,  AUTH_UNAUTHORIZED,  AUTH_FORBIDDEN,  USER_NOT_FOUND,  USER_EMAIL_ALREADY_EXISTS,  USER_PROFILE_NOT_FOUND,  USER_PREFERENCE_NOT_FOUND,  SESSION_NOT_FOUND,  NOTIFICATION_NOT_FOUND,  PUSH_DEVICE_NOT_FOUND,  REMINDER_NOT_FOUND,  MOOD_CHECKIN_NOT_FOUND,  JOURNAL_NOT_FOUND,  USER_COMPANION_NOT_FOUND,  RELAX_SESSION_NOT_FOUND,  PAYMENT_NOT_FOUND,  PAYMENT_NOT_PENDING,  PAYMENT_PLAN_MISMATCH,  CATALOG_APP_THEME_NOT_FOUND,  CATALOG_DEFAULT_APP_THEME_NOT_FOUND,  CATALOG_ONBOARDING_SLIDE_NOT_FOUND,  CATALOG_COMPANION_ASSET_NOT_FOUND,  CATALOG_DEFAULT_COMPANION_ASSET_NOT_FOUND,  CATALOG_COMPANION_MESSAGE_NOT_FOUND,  CATALOG_ACTIVE_COMPANION_MESSAGE_NOT_FOUND,  CATALOG_AMBIENT_SOUND_NOT_FOUND,  CATALOG_BREATHING_EXERCISE_NOT_FOUND,  CATALOG_COZY_QUOTE_NOT_FOUND,  CATALOG_ACTIVE_COZY_QUOTE_NOT_FOUND,  };

  @BuiltValueField(wireName: r'message')
  String get message;

  /// Optional validation messages, Prisma metadata, or provider details.
  @BuiltValueField(wireName: r'details')
  JsonObject? get details;

  @BuiltValueField(wireName: r'path')
  String get path;

  @BuiltValueField(wireName: r'timestamp')
  DateTime get timestamp;

  ErrorResponse._();

  factory ErrorResponse([void updates(ErrorResponseBuilder b)]) = _$ErrorResponse;

  @BuiltValueHook(initializeBuilder: true)
  static void _defaults(ErrorResponseBuilder b) => b;

  @BuiltValueSerializer(custom: true)
  static Serializer<ErrorResponse> get serializer => _$ErrorResponseSerializer();
}

class _$ErrorResponseSerializer implements PrimitiveSerializer<ErrorResponse> {
  @override
  final Iterable<Type> types = const [ErrorResponse, _$ErrorResponse];

  @override
  final String wireName = r'ErrorResponse';

  Iterable<Object?> _serializeProperties(
    Serializers serializers,
    ErrorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) sync* {
    yield r'success';
    yield serializers.serialize(
      object.success,
      specifiedType: const FullType(bool),
    );
    yield r'statusCode';
    yield serializers.serialize(
      object.statusCode,
      specifiedType: const FullType(int),
    );
    yield r'code';
    yield serializers.serialize(
      object.code,
      specifiedType: const FullType(ErrorResponseCodeEnum),
    );
    yield r'message';
    yield serializers.serialize(
      object.message,
      specifiedType: const FullType(String),
    );
    if (object.details != null) {
      yield r'details';
      yield serializers.serialize(
        object.details,
        specifiedType: const FullType.nullable(JsonObject),
      );
    }
    yield r'path';
    yield serializers.serialize(
      object.path,
      specifiedType: const FullType(String),
    );
    yield r'timestamp';
    yield serializers.serialize(
      object.timestamp,
      specifiedType: const FullType(DateTime),
    );
  }

  @override
  Object serialize(
    Serializers serializers,
    ErrorResponse object, {
    FullType specifiedType = FullType.unspecified,
  }) {
    return _serializeProperties(serializers, object, specifiedType: specifiedType).toList();
  }

  void _deserializeProperties(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
    required List<Object?> serializedList,
    required ErrorResponseBuilder result,
    required List<Object?> unhandled,
  }) {
    for (var i = 0; i < serializedList.length; i += 2) {
      final key = serializedList[i] as String;
      final value = serializedList[i + 1];
      switch (key) {
        case r'success':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(bool),
          ) as bool;
          result.success = valueDes;
          break;
        case r'statusCode':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(int),
          ) as int;
          result.statusCode = valueDes;
          break;
        case r'code':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(ErrorResponseCodeEnum),
          ) as ErrorResponseCodeEnum;
          result.code = valueDes;
          break;
        case r'message':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.message = valueDes;
          break;
        case r'details':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType.nullable(JsonObject),
          ) as JsonObject?;
          if (valueDes == null) continue;
          result.details = valueDes;
          break;
        case r'path':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(String),
          ) as String;
          result.path = valueDes;
          break;
        case r'timestamp':
          final valueDes = serializers.deserialize(
            value,
            specifiedType: const FullType(DateTime),
          ) as DateTime;
          result.timestamp = valueDes;
          break;
        default:
          unhandled.add(key);
          unhandled.add(value);
          break;
      }
    }
  }

  @override
  ErrorResponse deserialize(
    Serializers serializers,
    Object serialized, {
    FullType specifiedType = FullType.unspecified,
  }) {
    final result = ErrorResponseBuilder();
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

class ErrorResponseCodeEnum extends EnumClass {

  @BuiltValueEnumConst(wireName: r'VALIDATION_FAILED')
  static const ErrorResponseCodeEnum VALIDATION_FAILED = _$errorResponseCodeEnum_VALIDATION_FAILED;
  @BuiltValueEnumConst(wireName: r'ROUTE_NOT_FOUND')
  static const ErrorResponseCodeEnum ROUTE_NOT_FOUND = _$errorResponseCodeEnum_ROUTE_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'RATE_LIMIT_EXCEEDED')
  static const ErrorResponseCodeEnum RATE_LIMIT_EXCEEDED = _$errorResponseCodeEnum_RATE_LIMIT_EXCEEDED;
  @BuiltValueEnumConst(wireName: r'INTERNAL_SERVER_ERROR')
  static const ErrorResponseCodeEnum INTERNAL_SERVER_ERROR = _$errorResponseCodeEnum_INTERNAL_SERVER_ERROR;
  @BuiltValueEnumConst(wireName: r'CONFIG_MISSING_REQUIRED_ENV')
  static const ErrorResponseCodeEnum CONFIG_MISSING_REQUIRED_ENV = _$errorResponseCodeEnum_CONFIG_MISSING_REQUIRED_ENV;
  @BuiltValueEnumConst(wireName: r'STORAGE_NOT_CONFIGURED')
  static const ErrorResponseCodeEnum STORAGE_NOT_CONFIGURED = _$errorResponseCodeEnum_STORAGE_NOT_CONFIGURED;
  @BuiltValueEnumConst(wireName: r'STORAGE_INVALID_PATH')
  static const ErrorResponseCodeEnum STORAGE_INVALID_PATH = _$errorResponseCodeEnum_STORAGE_INVALID_PATH;
  @BuiltValueEnumConst(wireName: r'STORAGE_OPERATION_FAILED')
  static const ErrorResponseCodeEnum STORAGE_OPERATION_FAILED = _$errorResponseCodeEnum_STORAGE_OPERATION_FAILED;
  @BuiltValueEnumConst(wireName: r'DATABASE_UNIQUE_CONSTRAINT')
  static const ErrorResponseCodeEnum DATABASE_UNIQUE_CONSTRAINT = _$errorResponseCodeEnum_DATABASE_UNIQUE_CONSTRAINT;
  @BuiltValueEnumConst(wireName: r'DATABASE_FOREIGN_KEY_CONSTRAINT')
  static const ErrorResponseCodeEnum DATABASE_FOREIGN_KEY_CONSTRAINT = _$errorResponseCodeEnum_DATABASE_FOREIGN_KEY_CONSTRAINT;
  @BuiltValueEnumConst(wireName: r'DATABASE_RECORD_NOT_FOUND')
  static const ErrorResponseCodeEnum DATABASE_RECORD_NOT_FOUND = _$errorResponseCodeEnum_DATABASE_RECORD_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'AUTH_INVALID_CREDENTIALS')
  static const ErrorResponseCodeEnum AUTH_INVALID_CREDENTIALS = _$errorResponseCodeEnum_AUTH_INVALID_CREDENTIALS;
  @BuiltValueEnumConst(wireName: r'AUTH_INACTIVE_USER')
  static const ErrorResponseCodeEnum AUTH_INACTIVE_USER = _$errorResponseCodeEnum_AUTH_INACTIVE_USER;
  @BuiltValueEnumConst(wireName: r'AUTH_REFRESH_TOKEN_INVALID')
  static const ErrorResponseCodeEnum AUTH_REFRESH_TOKEN_INVALID = _$errorResponseCodeEnum_AUTH_REFRESH_TOKEN_INVALID;
  @BuiltValueEnumConst(wireName: r'AUTH_TOKEN_INVALID')
  static const ErrorResponseCodeEnum AUTH_TOKEN_INVALID = _$errorResponseCodeEnum_AUTH_TOKEN_INVALID;
  @BuiltValueEnumConst(wireName: r'AUTH_TOKEN_EXPIRED')
  static const ErrorResponseCodeEnum AUTH_TOKEN_EXPIRED = _$errorResponseCodeEnum_AUTH_TOKEN_EXPIRED;
  @BuiltValueEnumConst(wireName: r'AUTH_TOKEN_CONSUMED')
  static const ErrorResponseCodeEnum AUTH_TOKEN_CONSUMED = _$errorResponseCodeEnum_AUTH_TOKEN_CONSUMED;
  @BuiltValueEnumConst(wireName: r'AUTH_UNAUTHORIZED')
  static const ErrorResponseCodeEnum AUTH_UNAUTHORIZED = _$errorResponseCodeEnum_AUTH_UNAUTHORIZED;
  @BuiltValueEnumConst(wireName: r'AUTH_FORBIDDEN')
  static const ErrorResponseCodeEnum AUTH_FORBIDDEN = _$errorResponseCodeEnum_AUTH_FORBIDDEN;
  @BuiltValueEnumConst(wireName: r'USER_NOT_FOUND')
  static const ErrorResponseCodeEnum USER_NOT_FOUND = _$errorResponseCodeEnum_USER_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'USER_EMAIL_ALREADY_EXISTS')
  static const ErrorResponseCodeEnum USER_EMAIL_ALREADY_EXISTS = _$errorResponseCodeEnum_USER_EMAIL_ALREADY_EXISTS;
  @BuiltValueEnumConst(wireName: r'USER_PROFILE_NOT_FOUND')
  static const ErrorResponseCodeEnum USER_PROFILE_NOT_FOUND = _$errorResponseCodeEnum_USER_PROFILE_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'USER_PREFERENCE_NOT_FOUND')
  static const ErrorResponseCodeEnum USER_PREFERENCE_NOT_FOUND = _$errorResponseCodeEnum_USER_PREFERENCE_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'SESSION_NOT_FOUND')
  static const ErrorResponseCodeEnum SESSION_NOT_FOUND = _$errorResponseCodeEnum_SESSION_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'NOTIFICATION_NOT_FOUND')
  static const ErrorResponseCodeEnum NOTIFICATION_NOT_FOUND = _$errorResponseCodeEnum_NOTIFICATION_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'PUSH_DEVICE_NOT_FOUND')
  static const ErrorResponseCodeEnum PUSH_DEVICE_NOT_FOUND = _$errorResponseCodeEnum_PUSH_DEVICE_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'REMINDER_NOT_FOUND')
  static const ErrorResponseCodeEnum REMINDER_NOT_FOUND = _$errorResponseCodeEnum_REMINDER_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'MOOD_CHECKIN_NOT_FOUND')
  static const ErrorResponseCodeEnum MOOD_CHECKIN_NOT_FOUND = _$errorResponseCodeEnum_MOOD_CHECKIN_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'JOURNAL_NOT_FOUND')
  static const ErrorResponseCodeEnum JOURNAL_NOT_FOUND = _$errorResponseCodeEnum_JOURNAL_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'USER_COMPANION_NOT_FOUND')
  static const ErrorResponseCodeEnum USER_COMPANION_NOT_FOUND = _$errorResponseCodeEnum_USER_COMPANION_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'RELAX_SESSION_NOT_FOUND')
  static const ErrorResponseCodeEnum RELAX_SESSION_NOT_FOUND = _$errorResponseCodeEnum_RELAX_SESSION_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'PAYMENT_NOT_FOUND')
  static const ErrorResponseCodeEnum PAYMENT_NOT_FOUND = _$errorResponseCodeEnum_PAYMENT_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'PAYMENT_NOT_PENDING')
  static const ErrorResponseCodeEnum PAYMENT_NOT_PENDING = _$errorResponseCodeEnum_PAYMENT_NOT_PENDING;
  @BuiltValueEnumConst(wireName: r'PAYMENT_PLAN_MISMATCH')
  static const ErrorResponseCodeEnum PAYMENT_PLAN_MISMATCH = _$errorResponseCodeEnum_PAYMENT_PLAN_MISMATCH;
  @BuiltValueEnumConst(wireName: r'CATALOG_APP_THEME_NOT_FOUND')
  static const ErrorResponseCodeEnum CATALOG_APP_THEME_NOT_FOUND = _$errorResponseCodeEnum_CATALOG_APP_THEME_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'CATALOG_DEFAULT_APP_THEME_NOT_FOUND')
  static const ErrorResponseCodeEnum CATALOG_DEFAULT_APP_THEME_NOT_FOUND = _$errorResponseCodeEnum_CATALOG_DEFAULT_APP_THEME_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'CATALOG_ONBOARDING_SLIDE_NOT_FOUND')
  static const ErrorResponseCodeEnum CATALOG_ONBOARDING_SLIDE_NOT_FOUND = _$errorResponseCodeEnum_CATALOG_ONBOARDING_SLIDE_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'CATALOG_COMPANION_ASSET_NOT_FOUND')
  static const ErrorResponseCodeEnum CATALOG_COMPANION_ASSET_NOT_FOUND = _$errorResponseCodeEnum_CATALOG_COMPANION_ASSET_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'CATALOG_DEFAULT_COMPANION_ASSET_NOT_FOUND')
  static const ErrorResponseCodeEnum CATALOG_DEFAULT_COMPANION_ASSET_NOT_FOUND = _$errorResponseCodeEnum_CATALOG_DEFAULT_COMPANION_ASSET_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'CATALOG_COMPANION_MESSAGE_NOT_FOUND')
  static const ErrorResponseCodeEnum CATALOG_COMPANION_MESSAGE_NOT_FOUND = _$errorResponseCodeEnum_CATALOG_COMPANION_MESSAGE_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'CATALOG_ACTIVE_COMPANION_MESSAGE_NOT_FOUND')
  static const ErrorResponseCodeEnum CATALOG_ACTIVE_COMPANION_MESSAGE_NOT_FOUND = _$errorResponseCodeEnum_CATALOG_ACTIVE_COMPANION_MESSAGE_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'CATALOG_AMBIENT_SOUND_NOT_FOUND')
  static const ErrorResponseCodeEnum CATALOG_AMBIENT_SOUND_NOT_FOUND = _$errorResponseCodeEnum_CATALOG_AMBIENT_SOUND_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'CATALOG_BREATHING_EXERCISE_NOT_FOUND')
  static const ErrorResponseCodeEnum CATALOG_BREATHING_EXERCISE_NOT_FOUND = _$errorResponseCodeEnum_CATALOG_BREATHING_EXERCISE_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'CATALOG_COZY_QUOTE_NOT_FOUND')
  static const ErrorResponseCodeEnum CATALOG_COZY_QUOTE_NOT_FOUND = _$errorResponseCodeEnum_CATALOG_COZY_QUOTE_NOT_FOUND;
  @BuiltValueEnumConst(wireName: r'CATALOG_ACTIVE_COZY_QUOTE_NOT_FOUND')
  static const ErrorResponseCodeEnum CATALOG_ACTIVE_COZY_QUOTE_NOT_FOUND = _$errorResponseCodeEnum_CATALOG_ACTIVE_COZY_QUOTE_NOT_FOUND;

  static Serializer<ErrorResponseCodeEnum> get serializer => _$errorResponseCodeEnumSerializer;

  const ErrorResponseCodeEnum._(String name): super(name);

  static BuiltSet<ErrorResponseCodeEnum> get values => _$errorResponseCodeEnumValues;
  static ErrorResponseCodeEnum valueOf(String name) => _$errorResponseCodeEnumValueOf(name);
}

