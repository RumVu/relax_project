// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_greeting_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WeatherGreetingDto extends WeatherGreetingDto {
  @override
  final String title;
  @override
  final String subtitle;
  @override
  final String iconKey;

  factory _$WeatherGreetingDto(
          [void Function(WeatherGreetingDtoBuilder)? updates]) =>
      (WeatherGreetingDtoBuilder()..update(updates))._build();

  _$WeatherGreetingDto._(
      {required this.title, required this.subtitle, required this.iconKey})
      : super._();
  @override
  WeatherGreetingDto rebuild(
          void Function(WeatherGreetingDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WeatherGreetingDtoBuilder toBuilder() =>
      WeatherGreetingDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WeatherGreetingDto &&
        title == other.title &&
        subtitle == other.subtitle &&
        iconKey == other.iconKey;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, title.hashCode);
    _$hash = $jc(_$hash, subtitle.hashCode);
    _$hash = $jc(_$hash, iconKey.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WeatherGreetingDto')
          ..add('title', title)
          ..add('subtitle', subtitle)
          ..add('iconKey', iconKey))
        .toString();
  }
}

class WeatherGreetingDtoBuilder
    implements Builder<WeatherGreetingDto, WeatherGreetingDtoBuilder> {
  _$WeatherGreetingDto? _$v;

  String? _title;
  String? get title => _$this._title;
  set title(String? title) => _$this._title = title;

  String? _subtitle;
  String? get subtitle => _$this._subtitle;
  set subtitle(String? subtitle) => _$this._subtitle = subtitle;

  String? _iconKey;
  String? get iconKey => _$this._iconKey;
  set iconKey(String? iconKey) => _$this._iconKey = iconKey;

  WeatherGreetingDtoBuilder() {
    WeatherGreetingDto._defaults(this);
  }

  WeatherGreetingDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _title = $v.title;
      _subtitle = $v.subtitle;
      _iconKey = $v.iconKey;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WeatherGreetingDto other) {
    _$v = other as _$WeatherGreetingDto;
  }

  @override
  void update(void Function(WeatherGreetingDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WeatherGreetingDto build() => _build();

  _$WeatherGreetingDto _build() {
    final _$result = _$v ??
        _$WeatherGreetingDto._(
          title: BuiltValueNullFieldError.checkNotNull(
              title, r'WeatherGreetingDto', 'title'),
          subtitle: BuiltValueNullFieldError.checkNotNull(
              subtitle, r'WeatherGreetingDto', 'subtitle'),
          iconKey: BuiltValueNullFieldError.checkNotNull(
              iconKey, r'WeatherGreetingDto', 'iconKey'),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
