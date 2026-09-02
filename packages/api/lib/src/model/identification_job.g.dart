// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identification_job.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

const IdentificationJobStatusEnum _$identificationJobStatusEnum_pending =
    const IdentificationJobStatusEnum._('pending');
const IdentificationJobStatusEnum _$identificationJobStatusEnum_processing =
    const IdentificationJobStatusEnum._('processing');
const IdentificationJobStatusEnum _$identificationJobStatusEnum_identified =
    const IdentificationJobStatusEnum._('identified');
const IdentificationJobStatusEnum _$identificationJobStatusEnum_failed =
    const IdentificationJobStatusEnum._('failed');
const IdentificationJobStatusEnum _$identificationJobStatusEnum_cancelled =
    const IdentificationJobStatusEnum._('cancelled');

IdentificationJobStatusEnum _$identificationJobStatusEnumValueOf(String name) {
  switch (name) {
    case 'pending':
      return _$identificationJobStatusEnum_pending;
    case 'processing':
      return _$identificationJobStatusEnum_processing;
    case 'identified':
      return _$identificationJobStatusEnum_identified;
    case 'failed':
      return _$identificationJobStatusEnum_failed;
    case 'cancelled':
      return _$identificationJobStatusEnum_cancelled;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IdentificationJobStatusEnum>
    _$identificationJobStatusEnumValues =
    BuiltSet<IdentificationJobStatusEnum>(const <IdentificationJobStatusEnum>[
  _$identificationJobStatusEnum_pending,
  _$identificationJobStatusEnum_processing,
  _$identificationJobStatusEnum_identified,
  _$identificationJobStatusEnum_failed,
  _$identificationJobStatusEnum_cancelled,
]);

const IdentificationJobExpectedMatchEnum
    _$identificationJobExpectedMatchEnum_matched =
    const IdentificationJobExpectedMatchEnum._('matched');
const IdentificationJobExpectedMatchEnum
    _$identificationJobExpectedMatchEnum_mismatch =
    const IdentificationJobExpectedMatchEnum._('mismatch');

IdentificationJobExpectedMatchEnum _$identificationJobExpectedMatchEnumValueOf(
    String name) {
  switch (name) {
    case 'matched':
      return _$identificationJobExpectedMatchEnum_matched;
    case 'mismatch':
      return _$identificationJobExpectedMatchEnum_mismatch;
    default:
      throw ArgumentError(name);
  }
}

final BuiltSet<IdentificationJobExpectedMatchEnum>
    _$identificationJobExpectedMatchEnumValues = BuiltSet<
        IdentificationJobExpectedMatchEnum>(const <IdentificationJobExpectedMatchEnum>[
  _$identificationJobExpectedMatchEnum_matched,
  _$identificationJobExpectedMatchEnum_mismatch,
]);

Serializer<IdentificationJobStatusEnum>
    _$identificationJobStatusEnumSerializer =
    _$IdentificationJobStatusEnumSerializer();
Serializer<IdentificationJobExpectedMatchEnum>
    _$identificationJobExpectedMatchEnumSerializer =
    _$IdentificationJobExpectedMatchEnumSerializer();

class _$IdentificationJobStatusEnumSerializer
    implements PrimitiveSerializer<IdentificationJobStatusEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'pending': 'pending',
    'processing': 'processing',
    'identified': 'identified',
    'failed': 'failed',
    'cancelled': 'cancelled',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'pending': 'pending',
    'processing': 'processing',
    'identified': 'identified',
    'failed': 'failed',
    'cancelled': 'cancelled',
  };

  @override
  final Iterable<Type> types = const <Type>[IdentificationJobStatusEnum];
  @override
  final String wireName = 'IdentificationJobStatusEnum';

  @override
  Object serialize(Serializers serializers, IdentificationJobStatusEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IdentificationJobStatusEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IdentificationJobStatusEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$IdentificationJobExpectedMatchEnumSerializer
    implements PrimitiveSerializer<IdentificationJobExpectedMatchEnum> {
  static const Map<String, Object> _toWire = const <String, Object>{
    'matched': 'matched',
    'mismatch': 'mismatch',
  };
  static const Map<Object, String> _fromWire = const <Object, String>{
    'matched': 'matched',
    'mismatch': 'mismatch',
  };

  @override
  final Iterable<Type> types = const <Type>[IdentificationJobExpectedMatchEnum];
  @override
  final String wireName = 'IdentificationJobExpectedMatchEnum';

  @override
  Object serialize(
          Serializers serializers, IdentificationJobExpectedMatchEnum object,
          {FullType specifiedType = FullType.unspecified}) =>
      _toWire[object.name] ?? object.name;

  @override
  IdentificationJobExpectedMatchEnum deserialize(
          Serializers serializers, Object serialized,
          {FullType specifiedType = FullType.unspecified}) =>
      IdentificationJobExpectedMatchEnum.valueOf(
          _fromWire[serialized] ?? (serialized is String ? serialized : ''));
}

class _$IdentificationJob extends IdentificationJob {
  @override
  final String id;
  @override
  final IdentificationJobStatusEnum status;
  @override
  final DateTime createdAt;
  @override
  final int attempts;
  @override
  final DateTime? retryAfter;
  @override
  final BuiltList<IdentificationCandidate>? candidates;
  @override
  final IdentificationProviderMetadata? providerMetadata;
  @override
  final String? expectedPlantId;
  @override
  final IdentificationJobExpectedMatchEnum? expectedMatch;
  @override
  final String? expectedCandidateId;
  @override
  final String? failureCode;
  @override
  final DateTime? deadLetteredAt;
  @override
  final String? confirmedPlantId;
  @override
  final String? confirmedCandidateId;

  factory _$IdentificationJob(
          [void Function(IdentificationJobBuilder)? updates]) =>
      (IdentificationJobBuilder()..update(updates))._build();

  _$IdentificationJob._(
      {required this.id,
      required this.status,
      required this.createdAt,
      required this.attempts,
      this.retryAfter,
      this.candidates,
      this.providerMetadata,
      this.expectedPlantId,
      this.expectedMatch,
      this.expectedCandidateId,
      this.failureCode,
      this.deadLetteredAt,
      this.confirmedPlantId,
      this.confirmedCandidateId})
      : super._();
  @override
  IdentificationJob rebuild(void Function(IdentificationJobBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IdentificationJobBuilder toBuilder() =>
      IdentificationJobBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IdentificationJob &&
        id == other.id &&
        status == other.status &&
        createdAt == other.createdAt &&
        attempts == other.attempts &&
        retryAfter == other.retryAfter &&
        candidates == other.candidates &&
        providerMetadata == other.providerMetadata &&
        expectedPlantId == other.expectedPlantId &&
        expectedMatch == other.expectedMatch &&
        expectedCandidateId == other.expectedCandidateId &&
        failureCode == other.failureCode &&
        deadLetteredAt == other.deadLetteredAt &&
        confirmedPlantId == other.confirmedPlantId &&
        confirmedCandidateId == other.confirmedCandidateId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, id.hashCode);
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, createdAt.hashCode);
    _$hash = $jc(_$hash, attempts.hashCode);
    _$hash = $jc(_$hash, retryAfter.hashCode);
    _$hash = $jc(_$hash, candidates.hashCode);
    _$hash = $jc(_$hash, providerMetadata.hashCode);
    _$hash = $jc(_$hash, expectedPlantId.hashCode);
    _$hash = $jc(_$hash, expectedMatch.hashCode);
    _$hash = $jc(_$hash, expectedCandidateId.hashCode);
    _$hash = $jc(_$hash, failureCode.hashCode);
    _$hash = $jc(_$hash, deadLetteredAt.hashCode);
    _$hash = $jc(_$hash, confirmedPlantId.hashCode);
    _$hash = $jc(_$hash, confirmedCandidateId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IdentificationJob')
          ..add('id', id)
          ..add('status', status)
          ..add('createdAt', createdAt)
          ..add('attempts', attempts)
          ..add('retryAfter', retryAfter)
          ..add('candidates', candidates)
          ..add('providerMetadata', providerMetadata)
          ..add('expectedPlantId', expectedPlantId)
          ..add('expectedMatch', expectedMatch)
          ..add('expectedCandidateId', expectedCandidateId)
          ..add('failureCode', failureCode)
          ..add('deadLetteredAt', deadLetteredAt)
          ..add('confirmedPlantId', confirmedPlantId)
          ..add('confirmedCandidateId', confirmedCandidateId))
        .toString();
  }
}

class IdentificationJobBuilder
    implements Builder<IdentificationJob, IdentificationJobBuilder> {
  _$IdentificationJob? _$v;

  String? _id;
  String? get id => _$this._id;
  set id(String? id) => _$this._id = id;

  IdentificationJobStatusEnum? _status;
  IdentificationJobStatusEnum? get status => _$this._status;
  set status(IdentificationJobStatusEnum? status) => _$this._status = status;

  DateTime? _createdAt;
  DateTime? get createdAt => _$this._createdAt;
  set createdAt(DateTime? createdAt) => _$this._createdAt = createdAt;

  int? _attempts;
  int? get attempts => _$this._attempts;
  set attempts(int? attempts) => _$this._attempts = attempts;

  DateTime? _retryAfter;
  DateTime? get retryAfter => _$this._retryAfter;
  set retryAfter(DateTime? retryAfter) => _$this._retryAfter = retryAfter;

  ListBuilder<IdentificationCandidate>? _candidates;
  ListBuilder<IdentificationCandidate> get candidates =>
      _$this._candidates ??= ListBuilder<IdentificationCandidate>();
  set candidates(ListBuilder<IdentificationCandidate>? candidates) =>
      _$this._candidates = candidates;

  IdentificationProviderMetadataBuilder? _providerMetadata;
  IdentificationProviderMetadataBuilder get providerMetadata =>
      _$this._providerMetadata ??= IdentificationProviderMetadataBuilder();
  set providerMetadata(
          IdentificationProviderMetadataBuilder? providerMetadata) =>
      _$this._providerMetadata = providerMetadata;

  String? _expectedPlantId;
  String? get expectedPlantId => _$this._expectedPlantId;
  set expectedPlantId(String? expectedPlantId) =>
      _$this._expectedPlantId = expectedPlantId;

  IdentificationJobExpectedMatchEnum? _expectedMatch;
  IdentificationJobExpectedMatchEnum? get expectedMatch =>
      _$this._expectedMatch;
  set expectedMatch(IdentificationJobExpectedMatchEnum? expectedMatch) =>
      _$this._expectedMatch = expectedMatch;

  String? _expectedCandidateId;
  String? get expectedCandidateId => _$this._expectedCandidateId;
  set expectedCandidateId(String? expectedCandidateId) =>
      _$this._expectedCandidateId = expectedCandidateId;

  String? _failureCode;
  String? get failureCode => _$this._failureCode;
  set failureCode(String? failureCode) => _$this._failureCode = failureCode;

  DateTime? _deadLetteredAt;
  DateTime? get deadLetteredAt => _$this._deadLetteredAt;
  set deadLetteredAt(DateTime? deadLetteredAt) =>
      _$this._deadLetteredAt = deadLetteredAt;

  String? _confirmedPlantId;
  String? get confirmedPlantId => _$this._confirmedPlantId;
  set confirmedPlantId(String? confirmedPlantId) =>
      _$this._confirmedPlantId = confirmedPlantId;

  String? _confirmedCandidateId;
  String? get confirmedCandidateId => _$this._confirmedCandidateId;
  set confirmedCandidateId(String? confirmedCandidateId) =>
      _$this._confirmedCandidateId = confirmedCandidateId;

  IdentificationJobBuilder() {
    IdentificationJob._defaults(this);
  }

  IdentificationJobBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _id = $v.id;
      _status = $v.status;
      _createdAt = $v.createdAt;
      _attempts = $v.attempts;
      _retryAfter = $v.retryAfter;
      _candidates = $v.candidates?.toBuilder();
      _providerMetadata = $v.providerMetadata?.toBuilder();
      _expectedPlantId = $v.expectedPlantId;
      _expectedMatch = $v.expectedMatch;
      _expectedCandidateId = $v.expectedCandidateId;
      _failureCode = $v.failureCode;
      _deadLetteredAt = $v.deadLetteredAt;
      _confirmedPlantId = $v.confirmedPlantId;
      _confirmedCandidateId = $v.confirmedCandidateId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IdentificationJob other) {
    _$v = other as _$IdentificationJob;
  }

  @override
  void update(void Function(IdentificationJobBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IdentificationJob build() => _build();

  _$IdentificationJob _build() {
    _$IdentificationJob _$result;
    try {
      _$result = _$v ??
          _$IdentificationJob._(
            id: BuiltValueNullFieldError.checkNotNull(
                id, r'IdentificationJob', 'id'),
            status: BuiltValueNullFieldError.checkNotNull(
                status, r'IdentificationJob', 'status'),
            createdAt: BuiltValueNullFieldError.checkNotNull(
                createdAt, r'IdentificationJob', 'createdAt'),
            attempts: BuiltValueNullFieldError.checkNotNull(
                attempts, r'IdentificationJob', 'attempts'),
            retryAfter: retryAfter,
            candidates: _candidates?.build(),
            providerMetadata: _providerMetadata?.build(),
            expectedPlantId: expectedPlantId,
            expectedMatch: expectedMatch,
            expectedCandidateId: expectedCandidateId,
            failureCode: failureCode,
            deadLetteredAt: deadLetteredAt,
            confirmedPlantId: confirmedPlantId,
            confirmedCandidateId: confirmedCandidateId,
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'candidates';
        _candidates?.build();
        _$failedField = 'providerMetadata';
        _providerMetadata?.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
            r'IdentificationJob', _$failedField, e.toString());
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
