// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'provider_status_response_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ProviderStatusResponseDto extends ProviderStatusResponseDto {
  @override
  final bool configured;
  @override
  final JsonObject providers;

  factory _$ProviderStatusResponseDto(
          [void Function(ProviderStatusResponseDtoBuilder)? updates]) =>
      (ProviderStatusResponseDtoBuilder()..update(updates))._build();

  _$ProviderStatusResponseDto._(
      {required this.configured, required this.providers})
      : super._();
  @override
  ProviderStatusResponseDto rebuild(
          void Function(ProviderStatusResponseDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ProviderStatusResponseDtoBuilder toBuilder() =>
      ProviderStatusResponseDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ProviderStatusResponseDto &&
        configured == other.configured &&
        providers == other.providers;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, configured.hashCode);
    _$hash = $jc(_$hash, providers.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ProviderStatusResponseDto')
          ..add('configured', configured)
          ..add('providers', providers))
        .toString();
  }
}

class ProviderStatusResponseDtoBuilder
    implements
        Builder<ProviderStatusResponseDto, ProviderStatusResponseDtoBuilder> {
  _$ProviderStatusResponseDto? _$v;

  bool? _configured;
  bool? get configured => _$this._configured;
  set configured(bool? configured) => _$this._configured = configured;

  JsonObject? _providers;
  JsonObject? get providers => _$this._providers;
  set providers(JsonObject? providers) => _$this._providers = providers;

  ProviderStatusResponseDtoBuilder() {
    ProviderStatusResponseDto._defaults(this);
  }

  ProviderStatusResponseDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _configured = $v.configured;
      _providers = $v.providers;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ProviderStatusResponseDto other) {
    _$v = other as _$ProviderStatusResponseDto;
  }

  @override
  void update(void Function(ProviderStatusResponseDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ProviderStatusResponseDto build() => _build();

  _$ProviderStatusResponseDto _build() {
    final _$result = _$v ??
        _$ProviderStatusResponseDto._(
          configured: BuiltValueNullFieldError.checkNotNull(
              configured, r'ProviderStatusResponseDto', 'configured'),
          providers: BuiltValueNullFieldError.checkNotNull(
              providers, r'ProviderStatusResponseDto', 'providers'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
