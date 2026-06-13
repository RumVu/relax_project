// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserProfileResponseDto extends UserProfileResponseDto {
  @override
  final String id;
  @override
  final String userId;
  @override
  final String? displayName;
  @override
  final String? bio;
  @override
  final String? avatar;
  @override
  final DateTime? birthday;
  @override
  final String? zodiacSign;
  @override
  final String? chineseZodiac;
  @override
  final num totalMoodCheckins;
  @override
  final num totalJournalPosts;
  @override
  final num currentStreak;
  @override
  final num longestStreak;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;

  factory _$UserProfileResponseDto(
          [void Function(UserProfileResponseDtoBuilder)? updates]) =>
      (UserProfileResponseDtoBuilder()..update(updates))._build();

  _$UserProfileResponseDto._(
      {required this.id,
      required this.userId,
      this.displayName,
      this.bio,
      this.avatar,
      this.birthday,
      this.zodiacSign,
      this.chineseZodiac,
      required this.totalMoodCheckins,
      required this.totalJournalPosts,
      required this.currentStreak,
      required this.longestStreak,
      required this.createdAt,
      required this.updatedAt})
      : super._();
  @override
  UserProfileResponseDto rebuild(
          void Function(UserProfileResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserProfileResponseDtoBuilder toBuilder() =>
      UserProfileResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserProfileResponseDto &&
        id == other.id &&
        userId == other.userId &&
        displayName == other.displayName &&
        bio == other.bio &&
        avatar == other.avatar &&
        birthday == other.birthday &&
        zodiacSign == other.zodiacSign &&
        chineseZodiac == other.chineseZodiac &&
        totalMoodCheckins == other.totalMoodCheckins &&
        totalJournalPosts == other.totalJournalPosts &&
        currentStreak == other.currentStreak &&
        longestStreak == other.longestStreak &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, userId.hashCode);
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, bio.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jc(_$hash, birthday.hashCode);
    _$hash = $jc(_$hash, zodiacSign.hashCode);
    _$hash = $jc(_$hash, chineseZodiac.hashCode);
    _$hash = $jc(_$hash, totalMoodCheckins.hashCode);
    _$hash = $jc(_$hash, totalJournalPosts.hashCode);
    _$hash = $jc(_$hash, currentStreak.hashCode);
    _$hash = $jc(_$hash, longestStreak.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserProfileResponseDto')
          ..add('id', id)
          ..add('userId', userId)
          ..add('displayName', displayName)
          ..add('bio', bio)
          ..add('avatar', avatar)
          ..add('birthday', birthday)
          ..add('zodiacSign', zodiacSign)
          ..add('chineseZodiac', chineseZodiac)
          ..add('totalMoodCheckins', totalMoodCheckins)
          ..add('totalJournalPosts', totalJournalPosts)
          ..add('currentStreak', currentStreak)
          ..add('longestStreak', longestStreak)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt))
        .toString();
  }
}

class UserProfileResponseDtoBuilder
    implements Builder<UserProfileResponseDto, UserProfileResponseDtoBuilder> {
  _$UserProfileResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _userId;
  String? get userId => _$this._userId;
  set userId(String? userId) => _$this._userId = userId;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _bio;
  String? get bio => _$this._bio;
  set bio(String? bio) => _$this._bio = bio;

  String? _avatar;
  String? get avatar => _$this._avatar;
  set avatar(String? avatar) => _$this._avatar = avatar;

  DateTime? _birthday;
  DateTime? get birthday => _$this._birthday;
  set birthday(DateTime? birthday) => _$this._birthday = birthday;

  String? _zodiacSign;
  String? get zodiacSign => _$this._zodiacSign;
  set zodiacSign(String? zodiacSign) => _$this._zodiacSign = zodiacSign;

  String? _chineseZodiac;
  String? get chineseZodiac => _$this._chineseZodiac;
  set chineseZodiac(String? chineseZodiac) =>
      _$this._chineseZodiac = chineseZodiac;

  num? _totalMoodCheckins;
  num? get totalMoodCheckins => _$this._totalMoodCheckins;
  set totalMoodCheckins(num? totalMoodCheckins) =>
      _$this._totalMoodCheckins = totalMoodCheckins;

  num? _totalJournalPosts;
  num? get totalJournalPosts => _$this._totalJournalPosts;
  set totalJournalPosts(num? totalJournalPosts) =>
      _$this._totalJournalPosts = totalJournalPosts;

  num? _currentStreak;
  num? get currentStreak => _$this._currentStreak;
  set currentStreak(num? currentStreak) =>
      _$this._currentStreak = currentStreak;

  num? _longestStreak;
  num? get longestStreak => _$this._longestStreak;
  set longestStreak(num? longestStreak) =>
      _$this._longestStreak = longestStreak;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  UserProfileResponseDtoBuilder() {
    UserProfileResponseDto._defaults(this);
  }

  UserProfileResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _userId = $v.userId;
      _displayName = $v.displayName;
      _bio = $v.bio;
      _avatar = $v.avatar;
      _birthday = $v.birthday;
      _zodiacSign = $v.zodiacSign;
      _chineseZodiac = $v.chineseZodiac;
      _totalMoodCheckins = $v.totalMoodCheckins;
      _totalJournalPosts = $v.totalJournalPosts;
      _currentStreak = $v.currentStreak;
      _longestStreak = $v.longestStreak;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserProfileResponseDto other) {
    _$v = other as _$UserProfileResponseDto;
  }

  @override
  void update(void Function(UserProfileResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserProfileResponseDto build() => _build();

  _$UserProfileResponseDto _build() {
    final _$result = _$v ??
        _$UserProfileResponseDto._(
          id: BuiltValueNullFieldError.checkNotNull(
              id, r'UserProfileResponseDto', 'id'),
          userId: BuiltValueNullFieldError.checkNotNull(
              userId, r'UserProfileResponseDto', 'userId'),
          displayName: displayName,
          bio: bio,
          avatar: avatar,
          birthday: birthday,
          zodiacSign: zodiacSign,
          chineseZodiac: chineseZodiac,
          totalMoodCheckins: BuiltValueNullFieldError.checkNotNull(
              totalMoodCheckins,
              r'UserProfileResponseDto',
              'totalMoodCheckins'),
          totalJournalPosts: BuiltValueNullFieldError.checkNotNull(
              totalJournalPosts,
              r'UserProfileResponseDto',
              'totalJournalPosts'),
          currentStreak: BuiltValueNullFieldError.checkNotNull(
              currentStreak, r'UserProfileResponseDto', 'currentStreak'),
          longestStreak: BuiltValueNullFieldError.checkNotNull(
              longestStreak, r'UserProfileResponseDto', 'longestStreak'),
          createdAt: BuiltValueNullFieldError.checkNotNull(
              createdAt, r'UserProfileResponseDto', 'createdAt'),
          updatedAt: BuiltValueNullFieldError.checkNotNull(
              updatedAt, r'UserProfileResponseDto', 'updatedAt'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
