// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'journal_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$JournalResponseDto extends JournalResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final String? title;
  @override
  final String content;
  @override
  final JsonObject? mood;
  @override
  final BuiltList<String> tags;
  @override
  final bool isPrivate;
  @override
  final bool isFavorite;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$JournalResponseDto(
          [void Function(JournalResponseDtoBuilder)? updates]) =>
      (JournalResponseDtoBuilder()..update(updates))._build();

  _$JournalResponseDto._(
      {required this.id,
      required this.userId,
      this.title,
      required this.content,
      this.mood,
      required this.tags,
      required this.isPrivate,
      required this.isFavorite,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  JournalResponseDto rebuild(
          void Function(JournalResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  JournalResponseDtoBuilder toBuilder() =>
      JournalResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is JournalResponseDto &&
        id == other.id &&
        userId == other.userId &&
        title == other.title &&
        content == other.content &&
        mood == other.mood &&
        tags == other.tags &&
        isPrivate == other.isPrivate &&
        isFavorite == other.isFavorite &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, content.hashCode);
    _$hash = $jc(_$hash, mood.hashCode);
    _$hash = $jc(_$hash, tags.hashCode);
    _$hash = $jc(_$hash, isPrivate.hashCode);
    _$hash = $jc(_$hash, isFavorite.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'JournalResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('title', title)
          ..add('content', content)
          ..add('mood', mood)
          ..add('tags', tags)
          ..add('isPrivate', isPrivate)
          ..add('isFavorite', isFavorite)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class JournalResponseDtoBuilder
    implements Builder<JournalResponseDto, JournalResponseDtoBuilder> {
  _$JournalResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

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

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  JournalResponseDtoBuilder() {
    JournalResponseDto._defaults(this);
  }

  JournalResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _title = $v.title;
      _content = $v.content;
      _mood = $v.mood;
      _tags = $v.tags.toBuilder();
      _isPrivate = $v.isPrivate;
      _isFavorite = $v.isFavorite;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(JournalResponseDto other) {
    _$v = other as _$JournalResponseDto;
  }

  @override
  void update(void Function(JournalResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  JournalResponseDto build() => _build();

  _$JournalResponseDto _build() {
    _$JournalResponseDto _$result;
    try {
      _$result = _$v ??
          _$JournalResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'JournalResponseDto', 'id'),
            userId: BuiltValueNullFieldError.checkNotNull(
                userId, r'JournalResponseDto', 'userId'),
            title: title,
            content: BuiltValueNullFieldError.checkNotNull(
                content, r'JournalResponseDto', 'content'),
            mood: mood,
            tags: tags.build(),
            isPrivate: BuiltValueNullFieldError.checkNotNull(
                isPrivate, r'JournalResponseDto', 'isPrivate'),
            isFavorite: BuiltValueNullFieldError.checkNotNull(
                isFavorite, r'JournalResponseDto', 'isFavorite'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'JournalResponseDto', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'JournalResponseDto', 'updatedAt'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tags';
        tags.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'JournalResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
