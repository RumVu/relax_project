// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_journal_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateJournalDto extends CreateJournalDto {
  @override
  final String? title;
  @override
  final String content;
  @override
  final JsonObject? mood;
  @override
  final BuiltList<String>? tags;
  @override
  final bool? isPrivate;
  @override
  final bool? isFavorite;

  factory _$CreateJournalDto(
          [void Function(CreateJournalDtoBuilder)? updates]) =>
      (CreateJournalDtoBuilder()..update(updates))._build();

  _$CreateJournalDto._(
      {this.title,
      required this.content,
      this.mood,
      this.tags,
      this.isPrivate,
      this.isFavorite})
      : super._();
  @override
  CreateJournalDto rebuild(void Function(CreateJournalDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateJournalDtoBuilder toBuilder() =>
      CreateJournalDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateJournalDto &&
        title == other.title &&
        content == other.content &&
        mood == other.mood &&
        tags == other.tags &&
        isPrivate == other.isPrivate &&
        isFavorite == other.isFavorite;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, mood.hashCode);
    _$hash = $jc(_$hash, tags.hashCode);
    _$hash = $jc(_$hash, isPrivate.hashCode);
    _$hash = $jc(_$hash, isFavorite.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateJournalDto')
          ..add('title', title)
          ..add('content', content)
          ..add('mood', mood)
          ..add('tags', tags)
          ..add('isPrivate', isPrivate)
          ..add('isFavorite', isFavorite))
        .toString();
  }
}

class CreateJournalDtoBuilder
    implements Builder<CreateJournalDto, CreateJournalDtoBuilder> {
  _$CreateJournalDto? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _content;
  String? get content => _$this._content;
  set content(String? content) => _$this._content = content;

  JsonObject? _mood;
  JsonObject? get mood => _$this._mood;
  set mood(JsonObject? mood) => _$this._mood = mood;

  ListBuilder<String>? _tags;
  ListBuilder<String> get tags => _$this._tags ??= ListBuilder<String>();
  set tags(ListBuilder<String>? tags) => _$this._tags = tags;

  bool? _isPrivate;
  bool? get isPrivate => _$this._isPrivate;
  set isPrivate(bool? isPrivate) => _$this._isPrivate = isPrivate;

  bool? _isFavorite;
  bool? get isFavorite => _$this._isFavorite;
  set isFavorite(bool? isFavorite) => _$this._isFavorite = isFavorite;

  CreateJournalDtoBuilder() {
    CreateJournalDto._defaults(this);
  }

  CreateJournalDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _content = $v.content;
      _mood = $v.mood;
      _tags = $v.tags?.toBuilder();
      _isPrivate = $v.isPrivate;
      _isFavorite = $v.isFavorite;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateJournalDto other) {
    _$v = other as _$CreateJournalDto;
  }

  @override
  void update(void Function(CreateJournalDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateJournalDto build() => _build();

  _$CreateJournalDto _build() {
    _$CreateJournalDto _$result;
    try {
      _$result = _$v ??
          _$CreateJournalDto._(
            title: title,
            content: BuiltValueNullFieldError.checkNotNull(
                content, r'CreateJournalDto', 'content'),
            mood: mood,
            tags: _tags?.build(),
            isPrivate: isPrivate,
            isFavorite: isFavorite,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tags';
        _tags?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CreateJournalDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
