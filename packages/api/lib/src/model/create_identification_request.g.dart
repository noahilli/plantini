// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'create_identification_request.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$CreateIdentificationRequest extends CreateIdentificationRequest {
  @override
  final String clientJobId;
  @override
  final String mediaId;
  @override
  final String? expectedPlantId;

  factory _$CreateIdentificationRequest(
          [void Function(CreateIdentificationRequestBuilder)? updates]) =>
      (CreateIdentificationRequestBuilder()..update(updates))._build();

  _$CreateIdentificationRequest._(
      {required this.clientJobId, required this.mediaId, this.expectedPlantId})
      : super._();
  @override
  CreateIdentificationRequest rebuild(
          void Function(CreateIdentificationRequestBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  CreateIdentificationRequestBuilder toBuilder() =>
      CreateIdentificationRequestBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is CreateIdentificationRequest &&
        clientJobId == other.clientJobId &&
        mediaId == other.mediaId &&
        expectedPlantId == other.expectedPlantId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, clientJobId.hashCode);
    _$hash = $jc(_$hash, mediaId.hashCode);
    _$hash = $jc(_$hash, expectedPlantId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'CreateIdentificationRequest')
          ..add('clientJobId', clientJobId)
          ..add('mediaId', mediaId)
          ..add('expectedPlantId', expectedPlantId))
        .toString();
  }
}

class CreateIdentificationRequestBuilder
    implements
        Builder<CreateIdentificationRequest,
            CreateIdentificationRequestBuilder> {
  _$CreateIdentificationRequest? _$v;

  String? _clientJobId;
  String? get clientJobId => _$this._clientJobId;
  set clientJobId(String? clientJobId) => _$this._clientJobId = clientJobId;

  String? _mediaId;
  String? get mediaId => _$this._mediaId;
  set mediaId(String? mediaId) => _$this._mediaId = mediaId;

  String? _expectedPlantId;
  String? get expectedPlantId => _$this._expectedPlantId;
  set expectedPlantId(String? expectedPlantId) =>
      _$this._expectedPlantId = expectedPlantId;

  CreateIdentificationRequestBuilder() {
    CreateIdentificationRequest._defaults(this);
  }

  CreateIdentificationRequestBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _clientJobId = $v.clientJobId;
      _mediaId = $v.mediaId;
      _expectedPlantId = $v.expectedPlantId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(CreateIdentificationRequest other) {
    _$v = other as _$CreateIdentificationRequest;
  }

  @override
  void update(void Function(CreateIdentificationRequestBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  CreateIdentificationRequest build() => _build();

  _$CreateIdentificationRequest _build() {
    final _$result = _$v ??
        _$CreateIdentificationRequest._(
          clientJobId: BuiltValueNullFieldError.checkNotNull(
              clientJobId, r'CreateIdentificationRequest', 'clientJobId'),
          mediaId: BuiltValueNullFieldError.checkNotNull(
              mediaId, r'CreateIdentificationRequest', 'mediaId'),
          expectedPlantId: expectedPlantId,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
