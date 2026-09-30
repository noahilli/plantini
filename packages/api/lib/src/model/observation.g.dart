// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'observation.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const ObservationSyncStatusEnum _$observationSyncStatusEnum_synced =
    const ObservationSyncStatusEnum._('synced');
const ObservationSyncStatusEnum _$observationSyncStatusEnum_pending =
    const ObservationSyncStatusEnum._('pending');
const ObservationSyncStatusEnum _$observationSyncStatusEnum_conflict =
    const ObservationSyncStatusEnum._('conflict');
const ObservationSyncStatusEnum _$observationSyncStatusEnum_deleted =
    const ObservationSyncStatusEnum._('deleted');

ObservationSyncStatusEnum _$observationSyncStatusEnumValueOf(String name) {
  switch (name) {
    case 'synced':
      return _$observationSyncStatusEnum_synced;
    case 'pending':
      return _$observationSyncStatusEnum_pending;
    case 'conflict':
      return _$observationSyncStatusEnum_conflict;
    case 'deleted':
      return _$observationSyncStatusEnum_deleted;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<ObservationSyncStatusEnum> _$observationSyncStatusEnumValues =
    BuiltSet<ObservationSyncStatusEnum>(const <ObservationSyncStatusEnum>[
  _$observationSyncStatusEnum_synced,
  _$observationSyncStatusEnum_pending,
  _$observationSyncStatusEnum_conflict,
  _$observationSyncStatusEnum_deleted,
]);

Serializer<ObservationSyncStatusEnum> _$observationSyncStatusEnumSerializer =
    _$ObservationSyncStatusEnumSerializer();

class _$ObservationSyncStatusEnumSerializer
    implements PrimitiveSerializer<ObservationSyncStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'synced': 'synced',
    'pending': 'pending',
    'conflict': 'conflict',
    'deleted': 'deleted',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'synced': 'synced',
    'pending': 'pending',
    'conflict': 'conflict',
    'deleted': 'deleted',
  };

  @override
  final Iterable<Type> types = const <Type>[ObservationSyncStatusEnum];
  @override
  final String wireName = 'ObservationSyncStatusEnum';

  @override
  Object serialize(Serializers serializers, ObservationSyncStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  ObservationSyncStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      ObservationSyncStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$Observation extends Observation {
  @override
  final String id;
  @override
  final String clientObservationId;
  @override
  final DateTime observedAt;
  @override
  final String? note;
  @override
  final String? confirmedPlantId;
  @override
  final String? speciesKey;
  @override
  final String? speciesName;
  @override
  final String? mediaId;
  @override
  final String? mediaUrl;
  @override
  final ObservationLocation? location;
  @override
  final IdentificationJob? identification;
  @override
  final String version;
  @override
  final ObservationSyncStatusEnum syncStatus;

  factory _$Observation([void Function(ObservationBuilder)? updates]) =>
      (ObservationBuilder()..update(updates))._build();

  _$Observation._(
      {required this.id,
      required this.clientObservationId,
      required this.observedAt,
      this.note,
      this.confirmedPlantId,
      this.speciesKey,
      this.speciesName,
      this.mediaId,
      this.mediaUrl,
      this.location,
      this.identification,
      required this.version,
      required this.syncStatus})
      : super._();
  @override
  Observation rebuild(void Function(ObservationBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ObservationBuilder toBuilder() => ObservationBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is Observation &&
        id == other.id &&
        clientObservationId == other.clientObservationId &&
        observedAt == other.observedAt &&
        note == other.note &&
        confirmedPlantId == other.confirmedPlantId &&
        speciesKey == other.speciesKey &&
        speciesName == other.speciesName &&
        mediaId == other.mediaId &&
        mediaUrl == other.mediaUrl &&
        location == other.location &&
        identification == other.identification &&
        version == other.version &&
        syncStatus == other.syncStatus;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, clientObservationId.hashCode);
    _$hash = $jc(_$hash, observedAt.hashCode);
    _$hash = $jc(_$hash, note.hashCode);
    _$hash = $jc(_$hash, confirmedPlantId.hashCode);
    _$hash = $jc(_$hash, speciesKey.hashCode);
    _$hash = $jc(_$hash, speciesName.hashCode);
    _$hash = $jc(_$hash, mediaId.hashCode);
    _$hash = $jc(_$hash, mediaUrl.hashCode);
    _$hash = $jc(_$hash, location.hashCode);
    _$hash = $jc(_$hash, identification.hashCode);
    _$hash = $jc(_$hash, version.hashCode);
    _$hash = $jc(_$hash, syncStatus.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'Observation')
          ..add('id', id)
          ..add('clientObservationId', clientObservationId)
          ..add('observedAt', observedAt)
          ..add('note', note)
          ..add('confirmedPlantId', confirmedPlantId)
          ..add('speciesKey', speciesKey)
          ..add('speciesName', speciesName)
          ..add('mediaId', mediaId)
          ..add('mediaUrl', mediaUrl)
          ..add('location', location)
          ..add('identification', identification)
          ..add('version', version)
          ..add('syncStatus', syncStatus))
        .toString();
  }
}

class ObservationBuilder implements Builder<Observation, ObservationBuilder> {
  _$Observation? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

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

  String? _confirmedPlantId;
  String? get confirmedPlantId => _$this._confirmedPlantId;
  set confirmedPlantId(String? confirmedPlantId) =>
      _$this._confirmedPlantId = confirmedPlantId;

  String? _speciesKey;
  String? get speciesKey => _$this._speciesKey;
  set speciesKey(String? speciesKey) => _$this._speciesKey = speciesKey;

  String? _speciesName;
  String? get speciesName => _$this._speciesName;
  set speciesName(String? speciesName) => _$this._speciesName = speciesName;

  String? _mediaId;
  String? get mediaId => _$this._mediaId;
  set mediaId(String? mediaId) => _$this._mediaId = mediaId;

  String? _mediaUrl;
  String? get mediaUrl => _$this._mediaUrl;
  set mediaUrl(String? mediaUrl) => _$this._mediaUrl = mediaUrl;

  ObservationLocationBuilder? _location;
  ObservationLocationBuilder get location =>
      _$this._location ??= ObservationLocationBuilder();
  set location(ObservationLocationBuilder? location) =>
      _$this._location = location;

  IdentificationJobBuilder? _identification;
  IdentificationJobBuilder get identification =>
      _$this._identification ??= IdentificationJobBuilder();
  set identification(IdentificationJobBuilder? identification) =>
      _$this._identification = identification;

  String? _version;
  String? get version => _$this._version;
  set version(String? version) => _$this._version = version;

  ObservationSyncStatusEnum? _syncStatus;
  ObservationSyncStatusEnum? get syncStatus => _$this._syncStatus;
  set syncStatus(ObservationSyncStatusEnum? syncStatus) =>
      _$this._syncStatus = syncStatus;

  ObservationBuilder() {
    Observation._defaults(this);
  }

  ObservationBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _clientObservationId = $v.clientObservationId;
      _observedAt = $v.observedAt;
      _note = $v.note;
      _confirmedPlantId = $v.confirmedPlantId;
      _speciesKey = $v.speciesKey;
      _speciesName = $v.speciesName;
      _mediaId = $v.mediaId;
      _mediaUrl = $v.mediaUrl;
      _location = $v.location?.toBuilder();
      _identification = $v.identification?.toBuilder();
      _version = $v.version;
      _syncStatus = $v.syncStatus;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(Observation other) {
    _$v = other as _$Observation;
  }

  @override
  void update(void Function(ObservationBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  Observation build() => _build();

  _$Observation _build() {
    _$Observation _$result;
    try {
      _$result = _$v ??
          _$Observation._(
            id: BuiltValueNullFieldError.checkNotNull(id, r'Observation', 'id'),
            clientObservationId: BuiltValueNullFieldError.checkNotNull(
                clientObservationId, r'Observation', 'clientObservationId'),
            observedAt: BuiltValueNullFieldError.checkNotNull(
                observedAt, r'Observation', 'observedAt'),
            note: note,
            confirmedPlantId: confirmedPlantId,
            speciesKey: speciesKey,
            speciesName: speciesName,
            mediaId: mediaId,
            mediaUrl: mediaUrl,
            location: _location?.build(),
            identification: _identification?.build(),
            version: BuiltValueNullFieldError.checkNotNull(
                version, r'Observation', 'version'),
            syncStatus: BuiltValueNullFieldError.checkNotNull(
                syncStatus, r'Observation', 'syncStatus'),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'location';
        _location?.build();
        _$failedField = 'identification';
        _identification?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'Observation', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
