// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cozy_quote_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CozyQuoteResponseDto extends CozyQuoteResponseDto {
  @override
  final String id;
  @override
  final String content;
  @override
  final String? author;
  @override
  final JsonObject? mood;
  @override
  final String? imageUrl;
  @override
  final String lang;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$CozyQuoteResponseDto(
          [void Function(CozyQuoteResponseDtoBuilder)? updates]) =>
      (CozyQuoteResponseDtoBuilder()..update(updates))._build();

  _$CozyQuoteResponseDto._(
      {required this.id,
      required this.content,
      this.author,
      this.mood,
      this.imageUrl,
      required this.lang,
      required this.isActive,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  CozyQuoteResponseDto rebuild(
          void Function(CozyQuoteResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CozyQuoteResponseDtoBuilder toBuilder() =>
      CozyQuoteResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CozyQuoteResponseDto &&
        id == other.id &&
        content == other.content &&
        author == other.author &&
        mood == other.mood &&
        imageUrl == other.imageUrl &&
        lang == other.lang &&
        isActive == other.isActive &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jc(_$hash, mood.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, lang.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CozyQuoteResponseDto')
          ..add('id', id)
          ..add('content', content)
          ..add('author', author)
          ..add('mood', mood)
          ..add('imageUrl', imageUrl)
          ..add('lang', lang)
          ..add('isActive', isActive)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class CozyQuoteResponseDtoBuilder
    implements Builder<CozyQuoteResponseDto, CozyQuoteResponseDtoBuilder> {
  _$CozyQuoteResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  String? _author;
  String? get author => _$this._author;
  set author(String? author) => _$this._author = author;

  JsonObject? _mood;
  JsonObject? get mood => _$this._mood;
  set mood(JsonObject? mood) => _$this._mood = mood;

  String? _imageUrl;
  String? get imageUrl => _$this._imageUrl;
  set imageUrl(String? imageUrl) => _$this._imageUrl = imageUrl;

  String? _lang;
  String? get lang => _$this._lang;
  set lang(String? lang) => _$this._lang = lang;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  CozyQuoteResponseDtoBuilder() {
    CozyQuoteResponseDto._defaults(this);
  }

  CozyQuoteResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _content = $v.content;
      _author = $v.author;
      _mood = $v.mood;
      _imageUrl = $v.imageUrl;
      _lang = $v.lang;
      _isActive = $v.isActive;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CozyQuoteResponseDto other) {
    _$v = other as _$CozyQuoteResponseDto;
  }

  @override
  void update(void Function(CozyQuoteResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CozyQuoteResponseDto build() => _build();

  _$CozyQuoteResponseDto _build() {
    final _$result = _$v ??
        _$CozyQuoteResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'CozyQuoteResponseDto', 'id'),
          content: BuiltValueNullFieldError.checkNotNull(
              content, r'CozyQuoteResponseDto', 'content'),
          author: author,
          mood: mood,
          imageUrl: imageUrl,
          lang: BuiltValueNullFieldError.checkNotNull(
              lang, r'CozyQuoteResponseDto', 'lang'),
          isActive: BuiltValueNullFieldError.checkNotNull(
              isActive, r'CozyQuoteResponseDto', 'isActive'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'CozyQuoteResponseDto', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'CozyQuoteResponseDto', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
