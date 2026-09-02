// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_observation_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateObservationRequest extends CreateObservationRequest {
  @override
  final String clientObservationId;
  @override
  final DateTime observedAt;
  @override
  final String? note;
  @override
  final String? mediaId;
  @override
  final String? identificationJobId;
  @override
  final PrivateLocation? location;

  factory _$CreateObservationRequest(
          [void Function(CreateObservationRequestBuilder)? updates]) =>
      (CreateObservationRequestBuilder()..update(updates))._build();

  _$CreateObservationRequest._(
      {required this.clientObservationId,
      required this.observedAt,
      this.note,
      this.mediaId,
      this.identificationJobId,
      this.location})
      : super._();
  @override
  CreateObservationRequest rebuild(
          void Function(CreateObservationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateObservationRequestBuilder toBuilder() =>
      CreateObservationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateObservationRequest &&
        clientObservationId == other.clientObservationId &&
        observedAt == other.observedAt &&
        note == other.note &&
        mediaId == other.mediaId &&
        identificationJobId == other.identificationJobId &&
        location == other.location;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientObservationId.hashCode);
    _$hash = $jc(_$hash, observedAt.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, mediaId.hashCode);
    _$hash = $jc(_$hash, identificationJobId.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateObservationRequest')
          ..add('clientObservationId', clientObservationId)
          ..add('observedAt', observedAt)
          ..add('note', note)
          ..add('mediaId', mediaId)
          ..add('identificationJobId', identificationJobId)
          ..add('location', location))
        .toString();
  }
}

class CreateObservationRequestBuilder
    implements
        Builder<CreateObservationRequest, CreateObservationRequestBuilder> {
  _$CreateObservationRequest? _$v;

  String? _clientObservationId;
  String? get clientObservationId => _$this._clientObservationId;
  set clientObservationId(String? clientObservationId) =>
      _$this._clientObservationId = clientObservationId;

  DateTime? _observedAt;
  DateTime? get observedAt => _$this._observedAt;
  set observedAt(DateTime? observedAt) => _$this._observedAt = observedAt;

  String? _note;
  String? get note => _$this._note;
  set note(String? note) => _$this._note = note;

  String? _mediaId;
  String? get mediaId => _$this._mediaId;
  set mediaId(String? mediaId) => _$this._mediaId = mediaId;

  String? _identificationJobId;
  String? get identificationJobId => _$this._identificationJobId;
  set identificationJobId(String? identificationJobId) =>
      _$this._identificationJobId = identificationJobId;

  PrivateLocationBuilder? _location;
  PrivateLocationBuilder get location =>
      _$this._location ??= PrivateLocationBuilder();
  set location(PrivateLocationBuilder? location) => _$this._location = location;

  CreateObservationRequestBuilder() {
    CreateObservationRequest._defaults(this);
  }

  CreateObservationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientObservationId = $v.clientObservationId;
      _observedAt = $v.observedAt;
      _note = $v.note;
      _mediaId = $v.mediaId;
      _identificationJobId = $v.identificationJobId;
      _location = $v.location?.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateObservationRequest other) {
    _$v = other as _$CreateObservationRequest;
  }

  @override
  void update(void Function(CreateObservationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateObservationRequest build() => _build();

  _$CreateObservationRequest _build() {
    _$CreateObservationRequest _$result;
    try {
      _$result = _$v ??
          _$CreateObservationRequest._(
            clientObservationId: BuiltValueNullFieldError.checkNotNull(
                clientObservationId,
                r'CreateObservationRequest',
                'clientObservationId'),
            observedAt: BuiltValueNullFieldError.checkNotNull(
                observedAt, r'CreateObservationRequest', 'observedAt'),
            note: note,
            mediaId: mediaId,
            identificationJobId: identificationJobId,
            location: _location?.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        _location?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'CreateObservationRequest', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
