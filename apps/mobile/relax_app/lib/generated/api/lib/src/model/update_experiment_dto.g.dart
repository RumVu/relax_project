// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_experiment_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateExperimentDto extends UpdateExperimentDto {
  @override
  final String? key;
  @override
  final String? name;
  @override
  final String? description;
  @override
  final BuiltList<String>? variants;
  @override
  final bool? isActive;

  factory _$UpdateExperimentDto(
          [void Function(UpdateExperimentDtoBuilder)? updates]) =>
      (UpdateExperimentDtoBuilder()..update(updates))._build();

  _$UpdateExperimentDto._(
      {this.key, this.name, this.description, this.variants, this.isActive})
      : super._();
  @override
  UpdateExperimentDto rebuild(
          void Function(UpdateExperimentDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateExperimentDtoBuilder toBuilder() =>
      UpdateExperimentDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateExperimentDto &&
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
    return (newBuiltValueToStringHelper(r'UpdateExperimentDto')
          ..add('key', key)
          ..add('name', name)
          ..add('description', description)
          ..add('variants', variants)
          ..add('isActive', isActive))
        .toString();
  }
}

class UpdateExperimentDtoBuilder
    implements Builder<UpdateExperimentDto, UpdateExperimentDtoBuilder> {
  _$UpdateExperimentDto? _$v;

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

  UpdateExperimentDtoBuilder() {
    UpdateExperimentDto._defaults(this);
  }

  UpdateExperimentDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _name = $v.name;
      _description = $v.description;
      _variants = $v.variants?.toBuilder();
      _isActive = $v.isActive;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateExperimentDto other) {
    _$v = other as _$UpdateExperimentDto;
  }

  @override
  void update(void Function(UpdateExperimentDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateExperimentDto build() => _build();

  _$UpdateExperimentDto _build() {
    _$UpdateExperimentDto _$result;
    try {
      _$result = _$v ??
          _$UpdateExperimentDto._(
            key: key,
            name: name,
            description: description,
            variants: _variants?.build(),
            isActive: isActive,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'variants';
        _variants?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UpdateExperimentDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
