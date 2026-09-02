// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'identification_candidate.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$IdentificationCandidate extends IdentificationCandidate {
  @override
  final String candidateId;
  @override
  final String? plantId;
  @override
  final String scientificName;
  @override
  final String? commonName;
  @override
  final num score;
  @override
  final String? provider;
  @override
  final String? modelVersion;
  @override
  final String? safetyNotice;

  factory _$IdentificationCandidate(
          [void Function(IdentificationCandidateBuilder)? updates]) =>
      (IdentificationCandidateBuilder()..update(updates))._build();

  _$IdentificationCandidate._(
      {required this.candidateId,
      this.plantId,
      required this.scientificName,
      this.commonName,
      required this.score,
      this.provider,
      this.modelVersion,
      this.safetyNotice})
      : super._();
  @override
  IdentificationCandidate rebuild(
          void Function(IdentificationCandidateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  IdentificationCandidateBuilder toBuilder() =>
      IdentificationCandidateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is IdentificationCandidate &&
        candidateId == other.candidateId &&
        plantId == other.plantId &&
        scientificName == other.scientificName &&
        commonName == other.commonName &&
        score == other.score &&
        provider == other.provider &&
        modelVersion == other.modelVersion &&
        safetyNotice == other.safetyNotice;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, candidateId.hashCode);
    _$hash = $jc(_$hash, plantId.hashCode);
    _$hash = $jc(_$hash, scientificName.hashCode);
    _$hash = $jc(_$hash, commonName.hashCode);
    _$hash = $jc(_$hash, score.hashCode);
    _$hash = $jc(_$hash, provider.hashCode);
    _$hash = $jc(_$hash, modelVersion.hashCode);
    _$hash = $jc(_$hash, safetyNotice.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'IdentificationCandidate')
          ..add('candidateId', candidateId)
          ..add('plantId', plantId)
          ..add('scientificName', scientificName)
          ..add('commonName', commonName)
          ..add('score', score)
          ..add('provider', provider)
          ..add('modelVersion', modelVersion)
          ..add('safetyNotice', safetyNotice))
        .toString();
  }
}

class IdentificationCandidateBuilder
    implements
        Builder<IdentificationCandidate, IdentificationCandidateBuilder> {
  _$IdentificationCandidate? _$v;

  String? _candidateId;
  String? get candidateId => _$this._candidateId;
  set candidateId(String? candidateId) => _$this._candidateId = candidateId;

  String? _plantId;
  String? get plantId => _$this._plantId;
  set plantId(String? plantId) => _$this._plantId = plantId;

  String? _scientificName;
  String? get scientificName => _$this._scientificName;
  set scientificName(String? scientificName) =>
      _$this._scientificName = scientificName;

  String? _commonName;
  String? get commonName => _$this._commonName;
  set commonName(String? commonName) => _$this._commonName = commonName;

  num? _score;
  num? get score => _$this._score;
  set score(num? score) => _$this._score = score;

  String? _provider;
  String? get provider => _$this._provider;
  set provider(String? provider) => _$this._provider = provider;

  String? _modelVersion;
  String? get modelVersion => _$this._modelVersion;
  set modelVersion(String? modelVersion) => _$this._modelVersion = modelVersion;

  String? _safetyNotice;
  String? get safetyNotice => _$this._safetyNotice;
  set safetyNotice(String? safetyNotice) => _$this._safetyNotice = safetyNotice;

  IdentificationCandidateBuilder() {
    IdentificationCandidate._defaults(this);
  }

  IdentificationCandidateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _candidateId = $v.candidateId;
      _plantId = $v.plantId;
      _scientificName = $v.scientificName;
      _commonName = $v.commonName;
      _score = $v.score;
      _provider = $v.provider;
      _modelVersion = $v.modelVersion;
      _safetyNotice = $v.safetyNotice;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(IdentificationCandidate other) {
    _$v = other as _$IdentificationCandidate;
  }

  @override
  void update(void Function(IdentificationCandidateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  IdentificationCandidate build() => _build();

  _$IdentificationCandidate _build() {
    final _$result = _$v ??
        _$IdentificationCandidate._(
          candidateId: BuiltValueNullFieldError.checkNotNull(
              candidateId, r'IdentificationCandidate', 'candidateId'),
          plantId: plantId,
          scientificName: BuiltValueNullFieldError.checkNotNull(
              scientificName, r'IdentificationCandidate', 'scientificName'),
          commonName: commonName,
          score: BuiltValueNullFieldError.checkNotNull(
              score, r'IdentificationCandidate', 'score'),
          provider: provider,
          modelVersion: modelVersion,
          safetyNotice: safetyNotice,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
