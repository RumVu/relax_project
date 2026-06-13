// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'demo_login_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DemoLoginDto extends DemoLoginDto {
  @override
  final String? deviceName;

  factory _$DemoLoginDto([void Function(DemoLoginDtoBuilder)? updates]) =>
      (DemoLoginDtoBuilder()..update(updates))._build();

  _$DemoLoginDto._({this.deviceName}) : super._();
  @override
  DemoLoginDto rebuild(void Function(DemoLoginDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DemoLoginDtoBuilder toBuilder() => DemoLoginDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DemoLoginDto && deviceName == other.deviceName;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, deviceName.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DemoLoginDto')
          ..add('deviceName', deviceName))
        .toString();
  }
}

class DemoLoginDtoBuilder
    implements Builder<DemoLoginDto, DemoLoginDtoBuilder> {
  _$DemoLoginDto? _$v;

  String? _deviceName;
  String? get deviceName => _$this._deviceName;
  set deviceName(String? deviceName) => _$this._deviceName = deviceName;

  DemoLoginDtoBuilder() {
    DemoLoginDto._defaults(this);
  }

  DemoLoginDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _deviceName = $v.deviceName;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DemoLoginDto other) {
    _$v = other as _$DemoLoginDto;
  }

  @override
  void update(void Function(DemoLoginDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DemoLoginDto build() => _build();

  _$DemoLoginDto _build() {
    final _$result = _$v ??
        _$DemoLoginDto._(
          deviceName: deviceName,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
