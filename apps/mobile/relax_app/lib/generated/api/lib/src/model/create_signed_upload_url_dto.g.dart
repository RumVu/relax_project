// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_signed_upload_url_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateSignedUploadUrlDto extends CreateSignedUploadUrlDto {
  @override
  final String path;
  @override
  final bool? upsert;

  factory _$CreateSignedUploadUrlDto(
          [void Function(CreateSignedUploadUrlDtoBuilder)? updates]) =>
      (CreateSignedUploadUrlDtoBuilder()..update(updates))._build();

  _$CreateSignedUploadUrlDto._({required this.path, this.upsert}) : super._();
  @override
  CreateSignedUploadUrlDto rebuild(
          void Function(CreateSignedUploadUrlDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateSignedUploadUrlDtoBuilder toBuilder() =>
      CreateSignedUploadUrlDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateSignedUploadUrlDto &&
        path == other.path &&
        upsert == other.upsert;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, path.hashCode);
    _$hash = $jc(_$hash, upsert.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateSignedUploadUrlDto')
          ..add('path', path)
          ..add('upsert', upsert))
        .toString();
  }
}

class CreateSignedUploadUrlDtoBuilder
    implements
        Builder<CreateSignedUploadUrlDto, CreateSignedUploadUrlDtoBuilder> {
  _$CreateSignedUploadUrlDto? _$v;

  String? _path;
  String? get path => _$this._path;
  set path(String? path) => _$this._path = path;

  bool? _upsert;
  bool? get upsert => _$this._upsert;
  set upsert(bool? upsert) => _$this._upsert = upsert;

  CreateSignedUploadUrlDtoBuilder() {
    CreateSignedUploadUrlDto._defaults(this);
  }

  CreateSignedUploadUrlDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _path = $v.path;
      _upsert = $v.upsert;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateSignedUploadUrlDto other) {
    _$v = other as _$CreateSignedUploadUrlDto;
  }

  @override
  void update(void Function(CreateSignedUploadUrlDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateSignedUploadUrlDto build() => _build();

  _$CreateSignedUploadUrlDto _build() {
    final _$result = _$v ??
        _$CreateSignedUploadUrlDto._(
          path: BuiltValueNullFieldError.checkNotNull(
              path, r'CreateSignedUploadUrlDto', 'path'),
          upsert: upsert,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
