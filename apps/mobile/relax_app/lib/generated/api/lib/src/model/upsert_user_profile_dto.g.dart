// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'upsert_user_profile_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpsertUserProfileDto extends UpsertUserProfileDto {
  @override
  final String? displayName;
  @override
  final String? bio;
  @override
  final DateTime? birthday;
  @override
  final String? avatar;

  factory _$UpsertUserProfileDto(
          [void Function(UpsertUserProfileDtoBuilder)? updates]) =>
      (UpsertUserProfileDtoBuilder()..update(updates))._build();

  _$UpsertUserProfileDto._(
      {this.displayName, this.bio, this.birthday, this.avatar})
      : super._();
  @override
  UpsertUserProfileDto rebuild(
          void Function(UpsertUserProfileDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpsertUserProfileDtoBuilder toBuilder() =>
      UpsertUserProfileDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpsertUserProfileDto &&
        displayName == other.displayName &&
        bio == other.bio &&
        birthday == other.birthday &&
        avatar == other.avatar;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, displayName.hashCode);
    _$hash = $jc(_$hash, bio.hashCode);
    _$hash = $jc(_$hash, birthday.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpsertUserProfileDto')
          ..add('displayName', displayName)
          ..add('bio', bio)
          ..add('birthday', birthday)
          ..add('avatar', avatar))
        .toString();
  }
}

class UpsertUserProfileDtoBuilder
    implements Builder<UpsertUserProfileDto, UpsertUserProfileDtoBuilder> {
  _$UpsertUserProfileDto? _$v;

  String? _displayName;
  String? get displayName => _$this._displayName;
  set displayName(String? displayName) => _$this._displayName = displayName;

  String? _bio;
  String? get bio => _$this._bio;
  set bio(String? bio) => _$this._bio = bio;

  DateTime? _birthday;
  DateTime? get birthday => _$this._birthday;
  set birthday(DateTime? birthday) => _$this._birthday = birthday;

  String? _avatar;
  String? get avatar => _$this._avatar;
  set avatar(String? avatar) => _$this._avatar = avatar;

  UpsertUserProfileDtoBuilder() {
    UpsertUserProfileDto._defaults(this);
  }

  UpsertUserProfileDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _displayName = $v.displayName;
      _bio = $v.bio;
      _birthday = $v.birthday;
      _avatar = $v.avatar;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpsertUserProfileDto other) {
    _$v = other as _$UpsertUserProfileDto;
  }

  @override
  void update(void Function(UpsertUserProfileDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpsertUserProfileDto build() => _build();

  _$UpsertUserProfileDto _build() {
    final _$result = _$v ??
        _$UpsertUserProfileDto._(
          displayName: displayName,
          bio: bio,
          birthday: birthday,
          avatar: avatar,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
