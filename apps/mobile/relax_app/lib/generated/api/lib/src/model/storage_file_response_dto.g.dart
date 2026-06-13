// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'storage_file_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StorageFileResponseDto extends StorageFileResponseDto {
  @override
  final String id;
  @override
  final String? userId;
  @override
  final String filename;
  @override
  final String mimetype;
  @override
  final num size;
  @override
  final String provider;
  @override
  final String? path;
  @override
  final String url;
  @override
  final String? publicUrl;
  @override
  final String? bucket;
  @override
  final bool isPublic;
  @override
  final DateTime? expiresAt;
  @override
  final DateTime createdAt;

  factory _$StorageFileResponseDto(
          [void Function(StorageFileResponseDtoBuilder)? updates]) =>
      (StorageFileResponseDtoBuilder()..update(updates))._build();

  _$StorageFileResponseDto._(
      {required this.id,
      this.userId,
      required this.filename,
      required this.mimetype,
      required this.size,
      required this.provider,
      this.path,
      required this.url,
      this.publicUrl,
      this.bucket,
      required this.isPublic,
      this.expiresAt,
      required this.createdAt})
      : super._();
  @override
  StorageFileResponseDto rebuild(
          void Function(StorageFileResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StorageFileResponseDtoBuilder toBuilder() =>
      StorageFileResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StorageFileResponseDto &&
        id == other.id &&
        userId == other.userId &&
        filename == other.filename &&
        mimetype == other.mimetype &&
        size == other.size &&
        provider == other.provider &&
        path == other.path &&
        url == other.url &&
        publicUrl == other.publicUrl &&
        bucket == other.bucket &&
        isPublic == other.isPublic &&
        expiresAt == other.expiresAt &&
        createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, filename.hashCode);
    _$hash = $jc(_$hash, mimetype.hashCode);
    _$hash = $jc(_$hash, size.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, path.hashCode);
    _$hash = $jc(_$hash, url.hashCode);
    _$hash = $jc(_$hash, publicUrl.hashCode);
    _$hash = $jc(_$hash, bucket.hashCode);
    _$hash = $jc(_$hash, isPublic.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StorageFileResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('filename', filename)
          ..add('mimetype', mimetype)
          ..add('size', size)
          ..add('provider', provider)
          ..add('path', path)
          ..add('url', url)
          ..add('publicUrl', publicUrl)
          ..add('bucket', bucket)
          ..add('isPublic', isPublic)
          ..add('expiresAt', expiresAt)
          ..add('createdAt', createdAt))
        .toString();
  }
}

class StorageFileResponseDtoBuilder
    implements Builder<StorageFileResponseDto, StorageFileResponseDtoBuilder> {
  _$StorageFileResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _filename;
  String? get filename => _$this._filename;
  set filename(String? filename) => _$this._filename = filename;

  String? _mimetype;
  String? get mimetype => _$this._mimetype;
  set mimetype(String? mimetype) => _$this._mimetype = mimetype;

  num? _size;
  num? get size => _$this._size;
  set size(num? size) => _$this._size = size;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  String? _path;
  String? get path => _$this._path;
  set path(String? path) => _$this._path = path;

  String? _url;
  String? get url => _$this._url;
  set url(String? url) => _$this._url = url;

  String? _publicUrl;
  String? get publicUrl => _$this._publicUrl;
  set publicUrl(String? publicUrl) => _$this._publicUrl = publicUrl;

  String? _bucket;
  String? get bucket => _$this._bucket;
  set bucket(String? bucket) => _$this._bucket = bucket;

  bool? _isPublic;
  bool? get isPublic => _$this._isPublic;
  set isPublic(bool? isPublic) => _$this._isPublic = isPublic;

  DateTime? _expiresAt;
  DateTime? get expiresAt => _$this._expiresAt;
  set expiresAt(DateTime? expiresAt) => _$this._expiresAt = expiresAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  StorageFileResponseDtoBuilder() {
    StorageFileResponseDto._defaults(this);
  }

  StorageFileResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _filename = $v.filename;
      _mimetype = $v.mimetype;
      _size = $v.size;
      _provider = $v.provider;
      _path = $v.path;
      _url = $v.url;
      _publicUrl = $v.publicUrl;
      _bucket = $v.bucket;
      _isPublic = $v.isPublic;
      _expiresAt = $v.expiresAt;
      _createdAt = $v.createdAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StorageFileResponseDto other) {
    _$v = other as _$StorageFileResponseDto;
  }

  @override
  void update(void Function(StorageFileResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StorageFileResponseDto build() => _build();

  _$StorageFileResponseDto _build() {
    final _$result = _$v ??
        _$StorageFileResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'StorageFileResponseDto', 'id'),
          userId: userId,
          filename: BuiltValueNullFieldError.checkNotNull(
              filename, r'StorageFileResponseDto', 'filename'),
          mimetype: BuiltValueNullFieldError.checkNotNull(
              mimetype, r'StorageFileResponseDto', 'mimetype'),
          size: BuiltValueNullFieldError.checkNotNull(
              size, r'StorageFileResponseDto', 'size'),
          provider: BuiltValueNullFieldError.checkNotNull(
              provider, r'StorageFileResponseDto', 'provider'),
          path: path,
          url: BuiltValueNullFieldError.checkNotNull(
              url, r'StorageFileResponseDto', 'url'),
          publicUrl: publicUrl,
          bucket: bucket,
          isPublic: BuiltValueNullFieldError.checkNotNull(
              isPublic, r'StorageFileResponseDto', 'isPublic'),
          expiresAt: expiresAt,
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'StorageFileResponseDto', 'createdAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
