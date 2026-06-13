// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_companion_interaction_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateCompanionInteractionDto extends CreateCompanionInteractionDto {
  @override
  final String type;
  @override
  final JsonObject? metadata;

  factory _$CreateCompanionInteractionDto(
          [void Function(CreateCompanionInteractionDtoBuilder)? updates]) =>
      (CreateCompanionInteractionDtoBuilder()..update(updates))._build();

  _$CreateCompanionInteractionDto._({required this.type, this.metadata})
      : super._();
  @override
  CreateCompanionInteractionDto rebuild(
          void Function(CreateCompanionInteractionDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateCompanionInteractionDtoBuilder toBuilder() =>
      CreateCompanionInteractionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateCompanionInteractionDto &&
        type == other.type &&
        metadata == other.metadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, type.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateCompanionInteractionDto')
          ..add('type', type)
          ..add('metadata', metadata))
        .toString();
  }
}

class CreateCompanionInteractionDtoBuilder
    implements
        Builder<CreateCompanionInteractionDto,
            CreateCompanionInteractionDtoBuilder> {
  _$CreateCompanionInteractionDto? _$v;

  String? _type;
  String? get type => _$this._type;
  set type(String? type) => _$this._type = type;

  JsonObject? _metadata;
  JsonObject? get metadata => _$this._metadata;
  set metadata(JsonObject? metadata) => _$this._metadata = metadata;

  CreateCompanionInteractionDtoBuilder() {
    CreateCompanionInteractionDto._defaults(this);
  }

  CreateCompanionInteractionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _type = $v.type;
      _metadata = $v.metadata;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateCompanionInteractionDto other) {
    _$v = other as _$CreateCompanionInteractionDto;
  }

  @override
  void update(void Function(CreateCompanionInteractionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateCompanionInteractionDto build() => _build();

  _$CreateCompanionInteractionDto _build() {
    final _$result = _$v ??
        _$CreateCompanionInteractionDto._(
          type: BuiltValueNullFieldError.checkNotNull(
              type, r'CreateCompanionInteractionDto', 'type'),
          metadata: metadata,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
