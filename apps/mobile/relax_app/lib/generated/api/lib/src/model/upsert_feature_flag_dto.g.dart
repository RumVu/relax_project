// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upsert_feature_flag_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpsertFeatureFlagDto extends UpsertFeatureFlagDto {
  @override
  final String key;
  @override
  final String label;
  @override
  final String? description;
  @override
  final bool enabled;

  factory _$UpsertFeatureFlagDto(
          [void Function(UpsertFeatureFlagDtoBuilder)? updates]) =>
      (UpsertFeatureFlagDtoBuilder()..update(updates))._build();

  _$UpsertFeatureFlagDto._(
      {required this.key,
      required this.label,
      this.description,
      required this.enabled})
      : super._();
  @override
  UpsertFeatureFlagDto rebuild(
          void Function(UpsertFeatureFlagDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpsertFeatureFlagDtoBuilder toBuilder() =>
      UpsertFeatureFlagDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpsertFeatureFlagDto &&
        key == other.key &&
        label == other.label &&
        description == other.description &&
        enabled == other.enabled;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, key.hashCode);
    _$hash = $jc(_$hash, label.hashCode);
    _$hash = $jc(_$hash, description.hashCode);
    _$hash = $jc(_$hash, enabled.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpsertFeatureFlagDto')
          ..add('key', key)
          ..add('label', label)
          ..add('description', description)
          ..add('enabled', enabled))
        .toString();
  }
}

class UpsertFeatureFlagDtoBuilder
    implements Builder<UpsertFeatureFlagDto, UpsertFeatureFlagDtoBuilder> {
  _$UpsertFeatureFlagDto? _$v;

  String? _key;
  String? get key => _$this._key;
  set key(String? key) => _$this._key = key;

  String? _label;
  String? get label => _$this._label;
  set label(String? label) => _$this._label = label;

  String? _description;
  String? get description => _$this._description;
  set description(String? description) => _$this._description = description;

  bool? _enabled;
  bool? get enabled => _$this._enabled;
  set enabled(bool? enabled) => _$this._enabled = enabled;

  UpsertFeatureFlagDtoBuilder() {
    UpsertFeatureFlagDto._defaults(this);
  }

  UpsertFeatureFlagDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _key = $v.key;
      _label = $v.label;
      _description = $v.description;
      _enabled = $v.enabled;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpsertFeatureFlagDto other) {
    _$v = other as _$UpsertFeatureFlagDto;
  }

  @override
  void update(void Function(UpsertFeatureFlagDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpsertFeatureFlagDto build() => _build();

  _$UpsertFeatureFlagDto _build() {
    final _$result = _$v ??
        _$UpsertFeatureFlagDto._(
          key: BuiltValueNullFieldError.checkNotNull(
              key, r'UpsertFeatureFlagDto', 'key'),
          label: BuiltValueNullFieldError.checkNotNull(
              label, r'UpsertFeatureFlagDto', 'label'),
          description: description,
          enabled: BuiltValueNullFieldError.checkNotNull(
              enabled, r'UpsertFeatureFlagDto', 'enabled'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
