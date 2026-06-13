// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_experiment_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateExperimentDto extends CreateExperimentDto {
  @override
  final String key;
  @override
  final String name;
  @override
  final String? description;
  @override
  final BuiltList<String> variants;
  @override
  final bool? isActive;

  factory _$CreateExperimentDto(
          [void Function(CreateExperimentDtoBuilder)? updates]) =>
      (CreateExperimentDtoBuilder()..update(updates))._build();

  _$CreateExperimentDto._(
      {required this.key,
      required this.name,
      this.description,
      required this.variants,
      this.isActive})
      : super._();
  @override
  CreateExperimentDto rebuild(
          void Function(CreateExperimentDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateExperimentDtoBuilder toBuilder() =>
      CreateExperimentDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateExperimentDto &&
        key == other.key &&
        name == other.name &&
        description == other.description &&
        variants == other.variants &&
        isActive == other.isActive;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, variants.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateExperimentDto')
          ..add('key', key)
          ..add('name', name)
          ..add('description', description)
          ..add('variants', variants)
          ..add('isActive', isActive))
        .toString();
  }
}

class CreateExperimentDtoBuilder
    implements Builder<CreateExperimentDto, CreateExperimentDtoBuilder> {
  _$CreateExperimentDto? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  ListBuilder<String>? _variants;
  ListBuilder<String> get variants =>
      _$this._variants ??= ListBuilder<String>();
  set variants(ListBuilder<String>? variants) => _$this._variants = variants;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  CreateExperimentDtoBuilder() {
    CreateExperimentDto._defaults(this);
  }

  CreateExperimentDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _name = $v.name;
      _description = $v.description;
      _variants = $v.variants.toBuilder();
      _isActive = $v.isActive;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateExperimentDto other) {
    _$v = other as _$CreateExperimentDto;
  }

  @override
  void update(void Function(CreateExperimentDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateExperimentDto build() => _build();

  _$CreateExperimentDto _build() {
    _$CreateExperimentDto _$result;
    try {
      _$result = _$v ??
          _$CreateExperimentDto._(
            key: BuiltValueNullFieldError.checkNotNull(
                key, r'CreateExperimentDto', 'key'),
            name: BuiltValueNullFieldError.checkNotNull(
                name, r'CreateExperimentDto', 'name'),
            description: description,
            variants: variants.build(),
            isActive: isActive,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'variants';
        variants.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CreateExperimentDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
