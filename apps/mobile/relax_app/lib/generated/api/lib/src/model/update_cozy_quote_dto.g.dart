// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_cozy_quote_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateCozyQuoteDto extends UpdateCozyQuoteDto {
  @override
  final String? content;
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

  factory _$UpdateCozyQuoteDto(
          [void Function(UpdateCozyQuoteDtoBuilder)? updates]) =>
      (UpdateCozyQuoteDtoBuilder()..update(updates))._build();

  _$UpdateCozyQuoteDto._(
      {this.content,
      this.author,
      this.mood,
      this.imageUrl,
      this.lang,
      this.isActive})
      : super._();
  @override
  UpdateCozyQuoteDto rebuild(
          void Function(UpdateCozyQuoteDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateCozyQuoteDtoBuilder toBuilder() =>
      UpdateCozyQuoteDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateCozyQuoteDto &&
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
    return (newBuiltValueToStringHelper(r'UpdateCozyQuoteDto')
          ..add('content', content)
          ..add('author', author)
          ..add('mood', mood)
          ..add('imageUrl', imageUrl)
          ..add('lang', lang)
          ..add('isActive', isActive))
        .toString();
  }
}

class UpdateCozyQuoteDtoBuilder
    implements Builder<UpdateCozyQuoteDto, UpdateCozyQuoteDtoBuilder> {
  _$UpdateCozyQuoteDto? _$v;

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

  UpdateCozyQuoteDtoBuilder() {
    UpdateCozyQuoteDto._defaults(this);
  }

  UpdateCozyQuoteDtoBuilder get _$this {
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
  void replace(UpdateCozyQuoteDto other) {
    _$v = other as _$UpdateCozyQuoteDto;
  }

  @override
  void update(void Function(UpdateCozyQuoteDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateCozyQuoteDto build() => _build();

  _$UpdateCozyQuoteDto _build() {
    final _$result = _$v ??
        _$UpdateCozyQuoteDto._(
          content: content,
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
