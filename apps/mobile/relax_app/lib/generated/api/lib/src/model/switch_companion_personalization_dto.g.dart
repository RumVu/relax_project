// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'switch_companion_personalization_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SwitchCompanionPersonalizationDto
    extends SwitchCompanionPersonalizationDto {
  @override
  final JsonObject personalizationMode;
  @override
  final String? assetId;
  @override
  final bool? preserveProgress;
  @override
  final bool? resetVisualState;

  factory _$SwitchCompanionPersonalizationDto(
          [void Function(SwitchCompanionPersonalizationDtoBuilder)? updates]) =>
      (SwitchCompanionPersonalizationDtoBuilder()..update(updates))._build();

  _$SwitchCompanionPersonalizationDto._(
      {required this.personalizationMode,
      this.assetId,
      this.preserveProgress,
      this.resetVisualState})
      : super._();
  @override
  SwitchCompanionPersonalizationDto rebuild(
          void Function(SwitchCompanionPersonalizationDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SwitchCompanionPersonalizationDtoBuilder toBuilder() =>
      SwitchCompanionPersonalizationDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SwitchCompanionPersonalizationDto &&
        personalizationMode == other.personalizationMode &&
        assetId == other.assetId &&
        preserveProgress == other.preserveProgress &&
        resetVisualState == other.resetVisualState;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, personalizationMode.hashCode);
    _$hash = $jc(_$hash, assetId.hashCode);
    _$hash = $jc(_$hash, preserveProgress.hashCode);
    _$hash = $jc(_$hash, resetVisualState.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SwitchCompanionPersonalizationDto')
          ..add('personalizationMode', personalizationMode)
          ..add('assetId', assetId)
          ..add('preserveProgress', preserveProgress)
          ..add('resetVisualState', resetVisualState))
        .toString();
  }
}

class SwitchCompanionPersonalizationDtoBuilder
    implements
        Builder<SwitchCompanionPersonalizationDto,
            SwitchCompanionPersonalizationDtoBuilder> {
  _$SwitchCompanionPersonalizationDto? _$v;

  JsonObject? _personalizationMode;
  JsonObject? get personalizationMode => _$this._personalizationMode;
  set personalizationMode(JsonObject? personalizationMode) =>
      _$this._personalizationMode = personalizationMode;

  String? _assetId;
  String? get assetId => _$this._assetId;
  set assetId(String? assetId) => _$this._assetId = assetId;

  bool? _preserveProgress;
  bool? get preserveProgress => _$this._preserveProgress;
  set preserveProgress(bool? preserveProgress) =>
      _$this._preserveProgress = preserveProgress;

  bool? _resetVisualState;
  bool? get resetVisualState => _$this._resetVisualState;
  set resetVisualState(bool? resetVisualState) =>
      _$this._resetVisualState = resetVisualState;

  SwitchCompanionPersonalizationDtoBuilder() {
    SwitchCompanionPersonalizationDto._defaults(this);
  }

  SwitchCompanionPersonalizationDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _personalizationMode = $v.personalizationMode;
      _assetId = $v.assetId;
      _preserveProgress = $v.preserveProgress;
      _resetVisualState = $v.resetVisualState;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SwitchCompanionPersonalizationDto other) {
    _$v = other as _$SwitchCompanionPersonalizationDto;
  }

  @override
  void update(
      void Function(SwitchCompanionPersonalizationDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SwitchCompanionPersonalizationDto build() => _build();

  _$SwitchCompanionPersonalizationDto _build() {
    final _$result = _$v ??
        _$SwitchCompanionPersonalizationDto._(
          personalizationMode: BuiltValueNullFieldError.checkNotNull(
              personalizationMode,
              r'SwitchCompanionPersonalizationDto',
              'personalizationMode'),
          assetId: assetId,
          preserveProgress: preserveProgress,
          resetVisualState: resetVisualState,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
