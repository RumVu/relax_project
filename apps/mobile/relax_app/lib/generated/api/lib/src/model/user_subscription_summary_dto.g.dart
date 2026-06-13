// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_subscription_summary_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UserSubscriptionSummaryDto extends UserSubscriptionSummaryDto {
  @override
  final String id;
  @override
  final String planName;
  @override
  final String status;
  @override
  final DateTime? endDate;
  @override
  final TierNameDto? tier;

  factory _$UserSubscriptionSummaryDto(
          [void Function(UserSubscriptionSummaryDtoBuilder)? updates]) =>
      (UserSubscriptionSummaryDtoBuilder()..update(updates))._build();

  _$UserSubscriptionSummaryDto._(
      {required this.id,
      required this.planName,
      required this.status,
      this.endDate,
      this.tier})
      : super._();
  @override
  UserSubscriptionSummaryDto rebuild(
          void Function(UserSubscriptionSummaryDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UserSubscriptionSummaryDtoBuilder toBuilder() =>
      UserSubscriptionSummaryDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UserSubscriptionSummaryDto &&
        id == other.id &&
        planName == other.planName &&
        status == other.status &&
        endDate == other.endDate &&
        tier == other.tier;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, planName.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, endDate.hashCode);
    _$hash = $jc(_$hash, tier.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UserSubscriptionSummaryDto')
          ..add('id', id)
          ..add('planName', planName)
          ..add('status', status)
          ..add('endDate', endDate)
          ..add('tier', tier))
        .toString();
  }
}

class UserSubscriptionSummaryDtoBuilder
    implements
        Builder<UserSubscriptionSummaryDto, UserSubscriptionSummaryDtoBuilder> {
  _$UserSubscriptionSummaryDto? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  String? _planName;
  String? get planName => _$this._planName;
  set planName(String? planName) => _$this._planName = planName;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  DateTime? _endDate;
  DateTime? get endDate => _$this._endDate;
  set endDate(DateTime? endDate) => _$this._endDate = endDate;

  TierNameDtoBuilder? _tier;
  TierNameDtoBuilder get tier => _$this._tier ??= TierNameDtoBuilder();
  set tier(TierNameDtoBuilder? tier) => _$this._tier = tier;

  UserSubscriptionSummaryDtoBuilder() {
    UserSubscriptionSummaryDto._defaults(this);
  }

  UserSubscriptionSummaryDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _planName = $v.planName;
      _status = $v.status;
      _endDate = $v.endDate;
      _tier = $v.tier?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UserSubscriptionSummaryDto other) {
    _$v = other as _$UserSubscriptionSummaryDto;
  }

  @override
  void update(void Function(UserSubscriptionSummaryDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UserSubscriptionSummaryDto build() => _build();

  _$UserSubscriptionSummaryDto _build() {
    _$UserSubscriptionSummaryDto _$result;
    try {
      _$result = _$v ??
          _$UserSubscriptionSummaryDto._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'UserSubscriptionSummaryDto', 'id'),
            planName: BuiltValueNullFieldError.checkNotNull(
                planName, r'UserSubscriptionSummaryDto', 'planName'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'UserSubscriptionSummaryDto', 'status'),
            endDate: endDate,
            tier: _tier?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'tier';
        _tier?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'UserSubscriptionSummaryDto', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
