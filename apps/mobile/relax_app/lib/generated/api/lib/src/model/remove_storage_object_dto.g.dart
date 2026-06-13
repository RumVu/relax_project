// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'remove_storage_object_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RemoveStorageObjectDto extends RemoveStorageObjectDto {
  @override
  final BuiltList<String> paths;

  factory _$RemoveStorageObjectDto(
          [void Function(RemoveStorageObjectDtoBuilder)? updates]) =>
      (RemoveStorageObjectDtoBuilder()..update(updates))._build();

  _$RemoveStorageObjectDto._({required this.paths}) : super._();
  @override
  RemoveStorageObjectDto rebuild(
          void Function(RemoveStorageObjectDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RemoveStorageObjectDtoBuilder toBuilder() =>
      RemoveStorageObjectDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RemoveStorageObjectDto && paths == other.paths;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, paths.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RemoveStorageObjectDto')
          ..add('paths', paths))
        .toString();
  }
}

class RemoveStorageObjectDtoBuilder
    implements Builder<RemoveStorageObjectDto, RemoveStorageObjectDtoBuilder> {
  _$RemoveStorageObjectDto? _$v;

  ListBuilder<String>? _paths;
  ListBuilder<String> get paths => _$this._paths ??= ListBuilder<String>();
  set paths(ListBuilder<String>? paths) => _$this._paths = paths;

  RemoveStorageObjectDtoBuilder() {
    RemoveStorageObjectDto._defaults(this);
  }

  RemoveStorageObjectDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _paths = $v.paths.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RemoveStorageObjectDto other) {
    _$v = other as _$RemoveStorageObjectDto;
  }

  @override
  void update(void Function(RemoveStorageObjectDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RemoveStorageObjectDto build() => _build();

  _$RemoveStorageObjectDto _build() {
    _$RemoveStorageObjectDto _$result;
    try {
      _$result = _$v ??
          _$RemoveStorageObjectDto._(
            paths: paths.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'paths';
        paths.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'RemoveStorageObjectDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
