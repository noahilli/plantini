// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'confirm_identification_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ConfirmIdentificationRequest extends ConfirmIdentificationRequest {
  @override
  final String? candidateId;
  @override
  final String? confirmedPlantId;
  @override
  final bool? acceptMismatch;

  factory _$ConfirmIdentificationRequest(
          [void Function(ConfirmIdentificationRequestBuilder)? updates]) =>
      (ConfirmIdentificationRequestBuilder()..update(updates))._build();

  _$ConfirmIdentificationRequest._(
      {this.candidateId, this.confirmedPlantId, this.acceptMismatch})
      : super._();
  @override
  ConfirmIdentificationRequest rebuild(
          void Function(ConfirmIdentificationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ConfirmIdentificationRequestBuilder toBuilder() =>
      ConfirmIdentificationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ConfirmIdentificationRequest &&
        candidateId == other.candidateId &&
        confirmedPlantId == other.confirmedPlantId &&
        acceptMismatch == other.acceptMismatch;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, candidateId.hashCode);
    _$hash = $jc(_$hash, confirmedPlantId.hashCode);
    _$hash = $jc(_$hash, acceptMismatch.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ConfirmIdentificationRequest')
          ..add('candidateId', candidateId)
          ..add('confirmedPlantId', confirmedPlantId)
          ..add('acceptMismatch', acceptMismatch))
        .toString();
  }
}

class ConfirmIdentificationRequestBuilder
    implements
        Builder<ConfirmIdentificationRequest,
            ConfirmIdentificationRequestBuilder> {
  _$ConfirmIdentificationRequest? _$v;

  String? _candidateId;
  String? get candidateId => _$this._candidateId;
  set candidateId(String? candidateId) => _$this._candidateId = candidateId;

  String? _confirmedPlantId;
  String? get confirmedPlantId => _$this._confirmedPlantId;
  set confirmedPlantId(String? confirmedPlantId) =>
      _$this._confirmedPlantId = confirmedPlantId;

  bool? _acceptMismatch;
  bool? get acceptMismatch => _$this._acceptMismatch;
  set acceptMismatch(bool? acceptMismatch) =>
      _$this._acceptMismatch = acceptMismatch;

  ConfirmIdentificationRequestBuilder() {
    ConfirmIdentificationRequest._defaults(this);
  }

  ConfirmIdentificationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _candidateId = $v.candidateId;
      _confirmedPlantId = $v.confirmedPlantId;
      _acceptMismatch = $v.acceptMismatch;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ConfirmIdentificationRequest other) {
    _$v = other as _$ConfirmIdentificationRequest;
  }

  @override
  void update(void Function(ConfirmIdentificationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ConfirmIdentificationRequest build() => _build();

  _$ConfirmIdentificationRequest _build() {
    final _$result = _$v ??
        _$ConfirmIdentificationRequest._(
          candidateId: candidateId,
          confirmedPlantId: confirmedPlantId,
          acceptMismatch: acceptMismatch,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
