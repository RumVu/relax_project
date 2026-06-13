// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'delete_account_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const DeleteAccountDtoModeEnum _$deleteAccountDtoModeEnum_SOFT =
    const DeleteAccountDtoModeEnum._('SOFT');
const DeleteAccountDtoModeEnum _$deleteAccountDtoModeEnum_HARD =
    const DeleteAccountDtoModeEnum._('HARD');

DeleteAccountDtoModeEnum _$deleteAccountDtoModeEnumValueOf(String name) {
  switch (name) {
    case 'SOFT':
      return _$deleteAccountDtoModeEnum_SOFT;
    case 'HARD':
      return _$deleteAccountDtoModeEnum_HARD;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<DeleteAccountDtoModeEnum> _$deleteAccountDtoModeEnumValues =
    BuiltSet<DeleteAccountDtoModeEnum>(const <DeleteAccountDtoModeEnum>[
  _$deleteAccountDtoModeEnum_SOFT,
  _$deleteAccountDtoModeEnum_HARD,
]);

Serializer<DeleteAccountDtoModeEnum> _$deleteAccountDtoModeEnumSerializer =
    _$DeleteAccountDtoModeEnumSerializer();

class _$DeleteAccountDtoModeEnumSerializer
    implements PrimitiveSerializer<DeleteAccountDtoModeEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'SOFT': 'SOFT',
    'HARD': 'HARD',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'SOFT': 'SOFT',
    'HARD': 'HARD',
  };

  @override
  final Iterable<Type> types = const <Type>[DeleteAccountDtoModeEnum];
  @override
  final String wireName = 'DeleteAccountDtoModeEnum';

  @override
  Object serialize(Serializers serializers, DeleteAccountDtoModeEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  DeleteAccountDtoModeEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      DeleteAccountDtoModeEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$DeleteAccountDto extends DeleteAccountDto {
  @override
  final DeleteAccountDtoModeEnum? mode;
  @override
  final String? password;

  factory _$DeleteAccountDto(
          [void Function(DeleteAccountDtoBuilder)? updates]) =>
      (DeleteAccountDtoBuilder()..update(updates))._build();

  _$DeleteAccountDto._({this.mode, this.password}) : super._();
  @override
  DeleteAccountDto rebuild(void Function(DeleteAccountDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DeleteAccountDtoBuilder toBuilder() =>
      DeleteAccountDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DeleteAccountDto &&
        mode == other.mode &&
        password == other.password;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, mode.hashCode);
    _$hash = $jc(_$hash, password.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'DeleteAccountDto')
          ..add('mode', mode)
          ..add('password', password))
        .toString();
  }
}

class DeleteAccountDtoBuilder
    implements Builder<DeleteAccountDto, DeleteAccountDtoBuilder> {
  _$DeleteAccountDto? _$v;

  DeleteAccountDtoModeEnum? _mode;
  DeleteAccountDtoModeEnum? get mode => _$this._mode;
  set mode(DeleteAccountDtoModeEnum? mode) => _$this._mode = mode;

  String? _password;
  String? get password => _$this._password;
  set password(String? password) => _$this._password = password;

  DeleteAccountDtoBuilder() {
    DeleteAccountDto._defaults(this);
  }

  DeleteAccountDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _mode = $v.mode;
      _password = $v.password;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DeleteAccountDto other) {
    _$v = other as _$DeleteAccountDto;
  }

  @override
  void update(void Function(DeleteAccountDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DeleteAccountDto build() => _build();

  _$DeleteAccountDto _build() {
    final _$result = _$v ??
        _$DeleteAccountDto._(
          mode: mode,
          password: password,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
