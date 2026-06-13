// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserResponseDto extends UserResponseDto {
  @override
  final String id;
  @override
  final String email;
  @override
  final String? name;
  @override
  final String? avatar;
  @override
  final JsonObject role;
  @override
  final JsonObject authProvider;
  @override
  final bool emailVerified;
  @override
  final bool isActive;
  @override
  final DateTime? lastLoginAt;
  @override
  final DateTime? deletedAt;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  @override
  final UserProfileResponseDto? profile;
  @override
  final UserPreferenceResponseDto? preferences;
  @override
  final BuiltList<UserSubscriptionSummaryDto>? subscriptions;

  factory _$UserResponseDto([void Function(UserResponseDtoBuilder)? updates]) =>
      (UserResponseDtoBuilder()..update(updates))._build();

  _$UserResponseDto._(
      {required this.id,
      required this.email,
      this.name,
      this.avatar,
      required this.role,
      required this.authProvider,
      required this.emailVerified,
      required this.isActive,
      this.lastLoginAt,
      this.deletedAt,
      required this.createdAt,
      required this.updatedAt,
      this.profile,
      this.preferences,
      this.subscriptions})
      : super._();
  @override
  UserResponseDto rebuild(void Function(UserResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserResponseDtoBuilder toBuilder() => UserResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserResponseDto &&
        id == other.id &&
        email == other.email &&
        name == other.name &&
        avatar == other.avatar &&
        role == other.role &&
        authProvider == other.authProvider &&
        emailVerified == other.emailVerified &&
        isActive == other.isActive &&
        lastLoginAt == other.lastLoginAt &&
        deletedAt == other.deletedAt &&
        createdAt == other.createdAt &&
        updatedAt == other.updatedAt &&
        profile == other.profile &&
        preferences == other.preferences &&
        subscriptions == other.subscriptions;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, email.hashCode);
    _$hash = $jc(_$hash, name.hashCode);
    _$hash = $jc(_$hash, avatar.hashCode);
    _$hash = $jc(_$hash, role.hashCode);
    _$hash = $jc(_$hash, authProvider.hashCode);
    _$hash = $jc(_$hash, emailVerified.hashCode);
    _$hash = $jc(_$hash, isActive.hashCode);
    _$hash = $jc(_$hash, lastLoginAt.hashCode);
    _$hash = $jc(_$hash, deletedAt.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, updatedAt.hashCode);
    _$hash = $jc(_$hash, profile.hashCode);
    _$hash = $jc(_$hash, preferences.hashCode);
    _$hash = $jc(_$hash, subscriptions.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserResponseDto')
          ..add('id', id)
          ..add('email', email)
          ..add('name', name)
          ..add('avatar', avatar)
          ..add('role', role)
          ..add('authProvider', authProvider)
          ..add('emailVerified', emailVerified)
          ..add('isActive', isActive)
          ..add('lastLoginAt', lastLoginAt)
          ..add('deletedAt', deletedAt)
          ..add('createdAt', createdAt)
          ..add('updatedAt', updatedAt)
          ..add('profile', profile)
          ..add('preferences', preferences)
          ..add('subscriptions', subscriptions))
        .toString();
  }
}

class UserResponseDtoBuilder
    implements Builder<UserResponseDto, UserResponseDtoBuilder> {
  _$UserResponseDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _email;
  String? get email => _$this._email;
  set email(String? email) => _$this._email = email;

  String? _name;
  String? get name => _$this._name;
  set name(String? name) => _$this._name = name;

  String? _avatar;
  String? get avatar => _$this._avatar;
  set avatar(String? avatar) => _$this._avatar = avatar;

  JsonObject? _role;
  JsonObject? get role => _$this._role;
  set role(JsonObject? role) => _$this._role = role;

  JsonObject? _authProvider;
  JsonObject? get authProvider => _$this._authProvider;
  set authProvider(JsonObject? authProvider) =>
      _$this._authProvider = authProvider;

  bool? _emailVerified;
  bool? get emailVerified => _$this._emailVerified;
  set emailVerified(bool? emailVerified) =>
      _$this._emailVerified = emailVerified;

  bool? _isActive;
  bool? get isActive => _$this._isActive;
  set isActive(bool? isActive) => _$this._isActive = isActive;

  DateTime? _lastLoginAt;
  DateTime? get lastLoginAt => _$this._lastLoginAt;
  set lastLoginAt(DateTime? lastLoginAt) => _$this._lastLoginAt = lastLoginAt;

  DateTime? _deletedAt;
  DateTime? get deletedAt => _$this._deletedAt;
  set deletedAt(DateTime? deletedAt) => _$this._deletedAt = deletedAt;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  DateTime? _updatedAt;
  DateTime? get updatedAt => _$this._updatedAt;
  set updatedAt(DateTime? updatedAt) => _$this._updatedAt = updatedAt;

  UserProfileResponseDtoBuilder? _profile;
  UserProfileResponseDtoBuilder get profile =>
      _$this._profile ??= UserProfileResponseDtoBuilder();
  set profile(UserProfileResponseDtoBuilder? profile) =>
      _$this._profile = profile;

  UserPreferenceResponseDtoBuilder? _preferences;
  UserPreferenceResponseDtoBuilder get preferences =>
      _$this._preferences ??= UserPreferenceResponseDtoBuilder();
  set preferences(UserPreferenceResponseDtoBuilder? preferences) =>
      _$this._preferences = preferences;

  ListBuilder<UserSubscriptionSummaryDto>? _subscriptions;
  ListBuilder<UserSubscriptionSummaryDto> get subscriptions =>
      _$this._subscriptions ??= ListBuilder<UserSubscriptionSummaryDto>();
  set subscriptions(ListBuilder<UserSubscriptionSummaryDto>? subscriptions) =>
      _$this._subscriptions = subscriptions;

  UserResponseDtoBuilder() {
    UserResponseDto._defaults(this);
  }

  UserResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _email = $v.email;
      _name = $v.name;
      _avatar = $v.avatar;
      _role = $v.role;
      _authProvider = $v.authProvider;
      _emailVerified = $v.emailVerified;
      _isActive = $v.isActive;
      _lastLoginAt = $v.lastLoginAt;
      _deletedAt = $v.deletedAt;
      _createdAt = $v.createdAt;
      _updatedAt = $v.updatedAt;
      _profile = $v.profile?.toBuilder();
      _preferences = $v.preferences?.toBuilder();
      _subscriptions = $v.subscriptions?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserResponseDto other) {
    _$v = other as _$UserResponseDto;
  }

  @override
  void update(void Function(UserResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserResponseDto build() => _build();

  _$UserResponseDto _build() {
    _$UserResponseDto _$result;
    try {
      _$result = _$v ??
          _$UserResponseDto._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'UserResponseDto', 'id'),
            email: BuiltValueNullFieldError.checkNotNull(
                email, r'UserResponseDto', 'email'),
            name: name,
            avatar: avatar,
            role: BuiltValueNullFieldError.checkNotNull(
                role, r'UserResponseDto', 'role'),
            authProvider: BuiltValueNullFieldError.checkNotNull(
                authProvider, r'UserResponseDto', 'authProvider'),
            emailVerified: BuiltValueNullFieldError.checkNotNull(
                emailVerified, r'UserResponseDto', 'emailVerified'),
            isActive: BuiltValueNullFieldError.checkNotNull(
                isActive, r'UserResponseDto', 'isActive'),
            lastLoginAt: lastLoginAt,
            deletedAt: deletedAt,
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'UserResponseDto', 'createdAt'),
            updatedAt: BuiltValueNullFieldError.checkNotNull(
                updatedAt, r'UserResponseDto', 'updatedAt'),
            profile: _profile?.build(),
            preferences: _preferences?.build(),
            subscriptions: _subscriptions?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'profile';
        _profile?.build();
        _$failedField = 'preferences';
        _preferences?.build();
        _$failedField = 'subscriptions';
        _subscriptions?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UserResponseDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
