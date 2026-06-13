// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_storage_file_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$RegisterStorageFileDto extends RegisterStorageFileDto {
  @override
  final String filename;
  @override
  final String mimetype;
  @override
  final num size;
  @override
  final String path;
  @override
  final String? publicUrl;
  @override
  final bool? isPublic;
  @override
  final DateTime? expiresAt;
  @override
  final JsonObject? metadata;

  factory _$RegisterStorageFileDto(
          [void Function(RegisterStorageFileDtoBuilder)? updates]) =>
      (RegisterStorageFileDtoBuilder()..update(updates))._build();

  _$RegisterStorageFileDto._(
      {required this.filename,
      required this.mimetype,
      required this.size,
      required this.path,
      this.publicUrl,
      this.isPublic,
      this.expiresAt,
      this.metadata})
      : super._();
  @override
  RegisterStorageFileDto rebuild(
          void Function(RegisterStorageFileDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  RegisterStorageFileDtoBuilder toBuilder() =>
      RegisterStorageFileDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is RegisterStorageFileDto &&
        filename == other.filename &&
        mimetype == other.mimetype &&
        size == other.size &&
        path == other.path &&
        publicUrl == other.publicUrl &&
        isPublic == other.isPublic &&
        expiresAt == other.expiresAt &&
        metadata == other.metadata;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, filename.hashCode);
    _$hash = $jc(_$hash, mimetype.hashCode);
    _$hash = $jc(_$hash, size.hashCode);
    _$hash = $jc(_$hash, path.hashCode);
    _$hash = $jc(_$hash, publicUrl.hashCode);
    _$hash = $jc(_$hash, isPublic.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, metadata.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'RegisterStorageFileDto')
          ..add('filename', filename)
          ..add('mimetype', mimetype)
          ..add('size', size)
          ..add('path', path)
          ..add('publicUrl', publicUrl)
          ..add('isPublic', isPublic)
          ..add('expiresAt', expiresAt)
          ..add('metadata', metadata))
        .toString();
  }
}

class RegisterStorageFileDtoBuilder
    implements Builder<RegisterStorageFileDto, RegisterStorageFileDtoBuilder> {
  _$RegisterStorageFileDto? _$v;

  String? _filename;
  String? get filename => _$this._filename;
  set filename(String? filename) => _$this._filename = filename;

  String? _mimetype;
  String? get mimetype => _$this._mimetype;
  set mimetype(String? mimetype) => _$this._mimetype = mimetype;

  num? _size;
  num? get size => _$this._size;
  set size(num? size) => _$this._size = size;

  String? _path;
  String? get path => _$this._path;
  set path(String? path) => _$this._path = path;

  String? _publicUrl;
  String? get publicUrl => _$this._publicUrl;
  set publicUrl(String? publicUrl) => _$this._publicUrl = publicUrl;

  bool? _isPublic;
  bool? get isPublic => _$this._isPublic;
  set isPublic(bool? isPublic) => _$this._isPublic = isPublic;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  JsonObject? _metadata;
  JsonObject? get metadata => _$this._metadata;
  set metadata(JsonObject? metadata) => _$this._metadata = metadata;

  RegisterStorageFileDtoBuilder() {
    RegisterStorageFileDto._defaults(this);
  }

  RegisterStorageFileDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _filename = $v.filename;
      _mimetype = $v.mimetype;
      _size = $v.size;
      _path = $v.path;
      _publicUrl = $v.publicUrl;
      _isPublic = $v.isPublic;
      _expiresAt = $v.expiresAt;
      _metadata = $v.metadata;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(RegisterStorageFileDto other) {
    _$v = other as _$RegisterStorageFileDto;
  }

  @override
  void update(void Function(RegisterStorageFileDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  RegisterStorageFileDto build() => _build();

  _$RegisterStorageFileDto _build() {
    final _$result = _$v ??
        _$RegisterStorageFileDto._(
          filename: BuiltValueNullFieldError.checkNotNull(
              filename, r'RegisterStorageFileDto', 'filename'),
          mimetype: BuiltValueNullFieldError.checkNotNull(
              mimetype, r'RegisterStorageFileDto', 'mimetype'),
          size: BuiltValueNullFieldError.checkNotNull(
              size, r'RegisterStorageFileDto', 'size'),
          path: BuiltValueNullFieldError.checkNotNull(
              path, r'RegisterStorageFileDto', 'path'),
          publicUrl: publicUrl,
          isPublic: isPublic,
          expiresAt: expiresAt,
          metadata: metadata,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
