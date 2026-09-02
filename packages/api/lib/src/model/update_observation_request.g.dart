// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'update_observation_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$UpdateObservationRequest extends UpdateObservationRequest {
  @override
  final String? note;
  @override
  final String? confirmedPlantId;

  factory _$UpdateObservationRequest(
          [void Function(UpdateObservationRequestBuilder)? updates]) =>
      (UpdateObservationRequestBuilder()..update(updates))._build();

  _$UpdateObservationRequest._({this.note, this.confirmedPlantId}) : super._();
  @override
  UpdateObservationRequest rebuild(
          void Function(UpdateObservationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UpdateObservationRequestBuilder toBuilder() =>
      UpdateObservationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UpdateObservationRequest &&
        note == other.note &&
        confirmedPlantId == other.confirmedPlantId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, confirmedPlantId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'UpdateObservationRequest')
          ..add('note', note)
          ..add('confirmedPlantId', confirmedPlantId))
        .toString();
  }
}

class UpdateObservationRequestBuilder
    implements
        Builder<UpdateObservationRequest, UpdateObservationRequestBuilder> {
  _$UpdateObservationRequest? _$v;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  String? _confirmedPlantId;
  String? get confirmedPlantId => _$this._confirmedPlantId;
  set confirmedPlantId(String? confirmedPlantId) =>
      _$this._confirmedPlantId = confirmedPlantId;

  UpdateObservationRequestBuilder() {
    UpdateObservationRequest._defaults(this);
  }

  UpdateObservationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _note = $v.note;
      _confirmedPlantId = $v.confirmedPlantId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UpdateObservationRequest other) {
    _$v = other as _$UpdateObservationRequest;
  }

  @override
  void update(void Function(UpdateObservationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UpdateObservationRequest build() => _build();

  _$UpdateObservationRequest _build() {
    final _$result = _$v ??
        _$UpdateObservationRequest._(
          note: note,
          confirmedPlantId: confirmedPlantId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
