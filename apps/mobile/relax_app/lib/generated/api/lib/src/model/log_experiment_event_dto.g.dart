// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'log_experiment_event_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const LogExperimentEventDtoEventTypeEnum
    _$logExperimentEventDtoEventTypeEnum_viewed =
    const LogExperimentEventDtoEventTypeEnum._('viewed');
const LogExperimentEventDtoEventTypeEnum
    _$logExperimentEventDtoEventTypeEnum_converted =
    const LogExperimentEventDtoEventTypeEnum._('converted');

LogExperimentEventDtoEventTypeEnum _$logExperimentEventDtoEventTypeEnumValueOf(
    String name) {
  switch (name) {
    case 'viewed':
      return _$logExperimentEventDtoEventTypeEnum_viewed;
    case 'converted':
      return _$logExperimentEventDtoEventTypeEnum_converted;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<LogExperimentEventDtoEventTypeEnum>
    _$logExperimentEventDtoEventTypeEnumValues = BuiltSet<
        LogExperimentEventDtoEventTypeEnum>(const <LogExperimentEventDtoEventTypeEnum>[
  _$logExperimentEventDtoEventTypeEnum_viewed,
  _$logExperimentEventDtoEventTypeEnum_converted,
]);

Serializer<LogExperimentEventDtoEventTypeEnum>
    _$logExperimentEventDtoEventTypeEnumSerializer =
    _$LogExperimentEventDtoEventTypeEnumSerializer();

class _$LogExperimentEventDtoEventTypeEnumSerializer
    implements PrimitiveSerializer<LogExperimentEventDtoEventTypeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'viewed': 'viewed',
    'converted': 'converted',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'viewed': 'viewed',
    'converted': 'converted',
  };

  @override
  final Iterable<Type> types = const <Type>[LogExperimentEventDtoEventTypeEnum];
  @override
  final String wireName = 'LogExperimentEventDtoEventTypeEnum';

  @override
  Object serialize(
          Serializers serializers, LogExperimentEventDtoEventTypeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  LogExperimentEventDtoEventTypeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      LogExperimentEventDtoEventTypeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$LogExperimentEventDto extends LogExperimentEventDto {
  @override
  final String experimentKey;
  @override
  final String variant;
  @override
  final LogExperimentEventDtoEventTypeEnum eventType;

  factory _$LogExperimentEventDto(
          [void Function(LogExperimentEventDtoBuilder)? updates]) =>
      (LogExperimentEventDtoBuilder()..update(updates))._build();

  _$LogExperimentEventDto._(
      {required this.experimentKey,
      required this.variant,
      required this.eventType})
      : super._();
  @override
  LogExperimentEventDto rebuild(
          void Function(LogExperimentEventDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LogExperimentEventDtoBuilder toBuilder() =>
      LogExperimentEventDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LogExperimentEventDto &&
        experimentKey == other.experimentKey &&
        variant == other.variant &&
        eventType == other.eventType;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, experimentKey.hashCode);
    _$hash = $jc(_$hash, variant.hashCode);
    _$hash = $jc(_$hash, eventType.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LogExperimentEventDto')
          ..add('experimentKey', experimentKey)
          ..add('variant', variant)
          ..add('eventType', eventType))
        .toString();
  }
}

class LogExperimentEventDtoBuilder
    implements Builder<LogExperimentEventDto, LogExperimentEventDtoBuilder> {
  _$LogExperimentEventDto? _$v;

  String? _experimentKey;
  String? get experimentKey => _$this._experimentKey;
  set experimentKey(String? experimentKey) =>
      _$this._experimentKey = experimentKey;

  String? _variant;
  String? get variant => _$this._variant;
  set variant(String? variant) => _$this._variant = variant;

  LogExperimentEventDtoEventTypeEnum? _eventType;
  LogExperimentEventDtoEventTypeEnum? get eventType => _$this._eventType;
  set eventType(LogExperimentEventDtoEventTypeEnum? eventType) =>
      _$this._eventType = eventType;

  LogExperimentEventDtoBuilder() {
    LogExperimentEventDto._defaults(this);
  }

  LogExperimentEventDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _experimentKey = $v.experimentKey;
      _variant = $v.variant;
      _eventType = $v.eventType;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LogExperimentEventDto other) {
    _$v = other as _$LogExperimentEventDto;
  }

  @override
  void update(void Function(LogExperimentEventDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LogExperimentEventDto build() => _build();

  _$LogExperimentEventDto _build() {
    final _$result = _$v ??
        _$LogExperimentEventDto._(
          experimentKey: BuiltValueNullFieldError.checkNotNull(
              experimentKey, r'LogExperimentEventDto', 'experimentKey'),
          variant: BuiltValueNullFieldError.checkNotNull(
              variant, r'LogExperimentEventDto', 'variant'),
          eventType: BuiltValueNullFieldError.checkNotNull(
              eventType, r'LogExperimentEventDto', 'eventType'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
