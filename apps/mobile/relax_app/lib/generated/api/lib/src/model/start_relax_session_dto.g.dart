// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'start_relax_session_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$StartRelaxSessionDto extends StartRelaxSessionDto {
  @override
  final JsonObject activityType;
  @override
  final String? resourceId;
  @override
  final String? title;
  @override
  final JsonObject? moodBefore;

  factory _$StartRelaxSessionDto(
          [void Function(StartRelaxSessionDtoBuilder)? updates]) =>
      (StartRelaxSessionDtoBuilder()..update(updates))._build();

  _$StartRelaxSessionDto._(
      {required this.activityType,
      this.resourceId,
      this.title,
      this.moodBefore})
      : super._();
  @override
  StartRelaxSessionDto rebuild(
          void Function(StartRelaxSessionDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  StartRelaxSessionDtoBuilder toBuilder() =>
      StartRelaxSessionDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is StartRelaxSessionDto &&
        activityType == other.activityType &&
        resourceId == other.resourceId &&
        title == other.title &&
        moodBefore == other.moodBefore;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, activityType.hashCode);
    _$hash = $jc(_$hash, resourceId.hashCode);
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, moodBefore.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'StartRelaxSessionDto')
          ..add('activityType', activityType)
          ..add('resourceId', resourceId)
          ..add('title', title)
          ..add('moodBefore', moodBefore))
        .toString();
  }
}

class StartRelaxSessionDtoBuilder
    implements Builder<StartRelaxSessionDto, StartRelaxSessionDtoBuilder> {
  _$StartRelaxSessionDto? _$v;

  JsonObject? _activityType;
  JsonObject? get activityType => _$this._activityType;
  set activityType(JsonObject? activityType) =>
      _$this._activityType = activityType;

  String? _resourceId;
  String? get resourceId => _$this._resourceId;
  set resourceId(String? resourceId) => _$this._resourceId = resourceId;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  JsonObject? _moodBefore;
  JsonObject? get moodBefore => _$this._moodBefore;
  set moodBefore(JsonObject? moodBefore) => _$this._moodBefore = moodBefore;

  StartRelaxSessionDtoBuilder() {
    StartRelaxSessionDto._defaults(this);
  }

  StartRelaxSessionDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _activityType = $v.activityType;
      _resourceId = $v.resourceId;
      _title = $v.title;
      _moodBefore = $v.moodBefore;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(StartRelaxSessionDto other) {
    _$v = other as _$StartRelaxSessionDto;
  }

  @override
  void update(void Function(StartRelaxSessionDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  StartRelaxSessionDto build() => _build();

  _$StartRelaxSessionDto _build() {
    final _$result = _$v ??
        _$StartRelaxSessionDto._(
          activityType: BuiltValueNullFieldError.checkNotNull(
              activityType, r'StartRelaxSessionDto', 'activityType'),
          resourceId: resourceId,
          title: title,
          moodBefore: moodBefore,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
