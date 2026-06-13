// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'checkout_session_status_dto.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CheckoutSessionStatusDto extends CheckoutSessionStatusDto {
  @override
  final String status;
  @override
  final String note;
  @override
  final String? qrCodeUrl;
  @override
  final String? transferContent;
  @override
  final String? bankId;
  @override
  final String? accountNo;
  @override
  final String? accountName;
  @override
  final num? amount;
  @override
  final String? checkoutUrl;
  @override
  final JsonObject? checkoutFormfields;

  factory _$CheckoutSessionStatusDto(
          [void Function(CheckoutSessionStatusDtoBuilder)? updates]) =>
      (CheckoutSessionStatusDtoBuilder()..update(updates))._build();

  _$CheckoutSessionStatusDto._(
      {required this.status,
      required this.note,
      this.qrCodeUrl,
      this.transferContent,
      this.bankId,
      this.accountNo,
      this.accountName,
      this.amount,
      this.checkoutUrl,
      this.checkoutFormfields})
      : super._();
  @override
  CheckoutSessionStatusDto rebuild(
          void Function(CheckoutSessionStatusDtoBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CheckoutSessionStatusDtoBuilder toBuilder() =>
      CheckoutSessionStatusDtoBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CheckoutSessionStatusDto &&
        status == other.status &&
        note == other.note &&
        qrCodeUrl == other.qrCodeUrl &&
        transferContent == other.transferContent &&
        bankId == other.bankId &&
        accountNo == other.accountNo &&
        accountName == other.accountName &&
        amount == other.amount &&
        checkoutUrl == other.checkoutUrl &&
        checkoutFormfields == other.checkoutFormfields;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, qrCodeUrl.hashCode);
    _$hash = $jc(_$hash, transferContent.hashCode);
    _$hash = $jc(_$hash, bankId.hashCode);
    _$hash = $jc(_$hash, accountNo.hashCode);
    _$hash = $jc(_$hash, accountName.hashCode);
    _$hash = $jc(_$hash, amount.hashCode);
    _$hash = $jc(_$hash, checkoutUrl.hashCode);
    _$hash = $jc(_$hash, checkoutFormfields.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CheckoutSessionStatusDto')
          ..add('status', status)
          ..add('note', note)
          ..add('qrCodeUrl', qrCodeUrl)
          ..add('transferContent', transferContent)
          ..add('bankId', bankId)
          ..add('accountNo', accountNo)
          ..add('accountName', accountName)
          ..add('amount', amount)
          ..add('checkoutUrl', checkoutUrl)
          ..add('checkoutFormfields', checkoutFormfields))
        .toString();
  }
}

class CheckoutSessionStatusDtoBuilder
    implements
        Builder<CheckoutSessionStatusDto, CheckoutSessionStatusDtoBuilder> {
  _$CheckoutSessionStatusDto? _$v;

  String? _status;
  String? get status => _$this._status;
  set status(String? status) => _$this._status = status;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  String? _qrCodeUrl;
  String? get qrCodeUrl => _$this._qrCodeUrl;
  set qrCodeUrl(String? qrCodeUrl) => _$this._qrCodeUrl = qrCodeUrl;

  String? _transferContent;
  String? get transferContent => _$this._transferContent;
  set transferContent(String? transferContent) =>
      _$this._transferContent = transferContent;

  String? _bankId;
  String? get bankId => _$this._bankId;
  set bankId(String? bankId) => _$this._bankId = bankId;

  String? _accountNo;
  String? get accountNo => _$this._accountNo;
  set accountNo(String? accountNo) => _$this._accountNo = accountNo;

  String? _accountName;
  String? get accountName => _$this._accountName;
  set accountName(String? accountName) => _$this._accountName = accountName;

  num? _amount;
  num? get amount => _$this._amount;
  set amount(num? amount) => _$this._amount = amount;

  String? _checkoutUrl;
  String? get checkoutUrl => _$this._checkoutUrl;
  set checkoutUrl(String? checkoutUrl) => _$this._checkoutUrl = checkoutUrl;

  JsonObject? _checkoutFormfields;
  JsonObject? get checkoutFormfields => _$this._checkoutFormfields;
  set checkoutFormfields(JsonObject? checkoutFormfields) =>
      _$this._checkoutFormfields = checkoutFormfields;

  CheckoutSessionStatusDtoBuilder() {
    CheckoutSessionStatusDto._defaults(this);
  }

  CheckoutSessionStatusDtoBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _note = $v.note;
      _qrCodeUrl = $v.qrCodeUrl;
      _transferContent = $v.transferContent;
      _bankId = $v.bankId;
      _accountNo = $v.accountNo;
      _accountName = $v.accountName;
      _amount = $v.amount;
      _checkoutUrl = $v.checkoutUrl;
      _checkoutFormfields = $v.checkoutFormfields;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CheckoutSessionStatusDto other) {
    _$v = other as _$CheckoutSessionStatusDto;
  }

  @override
  void update(void Function(CheckoutSessionStatusDtoBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CheckoutSessionStatusDto build() => _build();

  _$CheckoutSessionStatusDto _build() {
    final _$result = _$v ??
        _$CheckoutSessionStatusDto._(
          status: BuiltValueNullFieldError.checkNotNull(
              status, r'CheckoutSessionStatusDto', 'status'),
          note: BuiltValueNullFieldError.checkNotNull(
              note, r'CheckoutSessionStatusDto', 'note'),
          qrCodeUrl: qrCodeUrl,
          transferContent: transferContent,
          bankId: bankId,
          accountNo: accountNo,
          accountName: accountName,
          amount: amount,
          checkoutUrl: checkoutUrl,
          checkoutFormfields: checkoutFormfields,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
