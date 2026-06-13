// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_cozy_quote_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateCozyQuoteDto extends CreateCozyQuoteDto {
  @override
  final String content;
  @override
  final String? author;
  @override
  final JsonObject? mood;
  @override
  final String? imageUrl;
  @override
  final String? lang;
  @override
  final bool? isActive;

  factory _$CreateCozyQuoteDto(
          [void Function(CreateCozyQuoteDtoBuilder)? updates]) =>
      (CreateCozyQuoteDtoBuilder()..update(updates))._build();

  _$CreateCozyQuoteDto._(
      {required this.content,
      this.author,
      this.mood,
      this.imageUrl,
      this.lang,
      this.isActive})
      : super._();
  @override
  CreateCozyQuoteDto rebuild(
          void Function(CreateCozyQuoteDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateCozyQuoteDtoBuilder toBuilder() =>
      CreateCozyQuoteDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateCozyQuoteDto &&
        content == other.content &&
        author == other.author &&
        mood == other.mood &&
        imageUrl == other.imageUrl &&
        lang == other.lang &&
        isActive == other.isActive;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, author.hashCode);
    _$hash = $jc(_$hash, mood.hashCode);
    _$hash = $jc(_$hash, imageUrl.hashCode);
    _$hash = $jc(_$hash, lang.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateCozyQuoteDto')
          ..add('content', content)
          ..add('author', author)
          ..add('mood', mood)
          ..add('imageUrl', imageUrl)
          ..add('lang', lang)
          ..add('isActive', isActive))
        .toString();
  }
}

class CreateCozyQuoteDtoBuilder
    implements Builder<CreateCozyQuoteDto, CreateCozyQuoteDtoBuilder> {
  _$CreateCozyQuoteDto? _$v;

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

  CreateCozyQuoteDtoBuilder() {
    CreateCozyQuoteDto._defaults(this);
  }

  CreateCozyQuoteDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _content = $v.content;
      _author = $v.author;
      _mood = $v.mood;
      _imageUrl = $v.imageUrl;
      _lang = $v.lang;
      _isActive = $v.isActive;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateCozyQuoteDto other) {
    _$v = other as _$CreateCozyQuoteDto;
  }

  @override
  void update(void Function(CreateCozyQuoteDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateCozyQuoteDto build() => _build();

  _$CreateCozyQuoteDto _build() {
    final _$result = _$v ??
        _$CreateCozyQuoteDto._(
          content: BuiltValueNullFieldError.checkNotNull(
              content, r'CreateCozyQuoteDto', 'content'),
          author: author,
          mood: mood,
          imageUrl: imageUrl,
          lang: lang,
          isActive: isActive,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
