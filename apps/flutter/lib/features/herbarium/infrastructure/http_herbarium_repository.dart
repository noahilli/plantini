import '../../../adapters/http/platform_api_client.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../../field/domain/field_models.dart';
import '../domain/herbarium_models.dart';
import '../domain/herbarium_repository.dart';

/// Caller-owned herbarium adapter for the canonical v1 observation API.
///
/// It intentionally maps only API fields. A client must not manufacture a
/// botanical name, media URL, location, or synchronized state locally.
final class HttpHerbariumRepository implements HerbariumRepository {
  const HttpHerbariumRepository(this._client);

  final PlatformApiClient _client;

  @override
  Future<Result<List<HerbariumEntry>>> listEntries({
    int page = 1,
    int pageSize = 20,
  }) async {
    final response = await _client.getJson(
      'observations',
      queryParameters: {'page': page, 'pageSize': pageSize},
    );
    return response.when(
      success: (value) => _observationPage(value.body),
      failure: Result.failure,
    );
  }

  @override
  Future<Result<HerbariumEntry>> getEntry(String id) async {
    final response = await _client.getJson('observations/$id');
    return response.when(
      success: (value) => _observation(value.body),
      failure: Result.failure,
    );
  }

  @override
  Future<Result<HerbariumEntry>> createEntry({
    required String clientObservationId,
    required DateTime observedAt,
    String? note,
    String? mediaId,
    String? mediaUrl,
    String? plantName,
    String? scientificName,
    String? identificationResult,
    String? identificationJobId,
    double? latitude,
    double? longitude,
    double? accuracyMeters,
    required String idempotencyKey,
  }) async {
    if (latitude != null || longitude != null || accuracyMeters != null) {
      if (latitude == null || longitude == null || accuracyMeters == null) {
        return const Result.failure(
          ValidationFailure(
            message: 'Ein Standort benötigt Breite, Länge und Genauigkeit.',
          ),
        );
      }
    }
    final response = await _client.postJson(
      'observations',
      idempotencyKey: idempotencyKey,
      body: {
        'clientObservationId': clientObservationId,
        'observedAt': observedAt.toUtc().toIso8601String(),
        if (note != null && note.isNotEmpty) 'note': note,
        if (mediaId != null) 'mediaId': mediaId,
        if (identificationJobId != null)
          'identificationJobId': identificationJobId,
        if (latitude != null)
          'location': {
            'latitude': latitude,
            'longitude': longitude,
            'accuracyMeters': accuracyMeters,
          },
      },
    );
    return response.when(
      success: (value) => _observation(value.body),
      failure: Result.failure,
    );
  }

  @override
  Future<Result<void>> deleteEntry({
    required String id,
    required String ifMatchVersion,
  }) async {
    final response = await _client.deleteJson(
      'observations/$id',
      ifMatchVersion: ifMatchVersion,
    );
    return response.when(
      success: (_) => const Result.success(null),
      failure: Result.failure,
    );
  }

  @override
  Future<Result<List<HerbariumEntry>>> syncEntries() => listEntries();
}

Result<List<HerbariumEntry>> _observationPage(Map<String, dynamic> body) {
  final items = body['items'];
  if (items is! List) {
    return _contractFailure(
      'Die Herbarium-Antwort benötigt ein items-Array.',
      const ['items'],
    );
  }
  final entries = <HerbariumEntry>[];
  for (var index = 0; index < items.length; index++) {
    final raw = items[index];
    if (raw is! Map<String, dynamic>) {
      return _contractFailure('Ein Herbarium-Eintrag ist ungültig.', [
        'items[$index]',
      ]);
    }
    final entry = _observation(raw);
    if (entry case Failure<HerbariumEntry>(:final failure)) {
      return Result.failure(failure);
    }
    entries.add((entry as Success<HerbariumEntry>).value);
  }
  return Result.success(entries);
}

Result<HerbariumEntry> _observation(Map<String, dynamic> body) {
  final id = _requiredString(body, 'id');
  final observedAt = _date(body['observedAt']);
  final version = _requiredString(body, 'version');
  final syncStatus = _syncStatus(body['syncStatus']);
  if (id == null ||
      observedAt == null ||
      version == null ||
      syncStatus == null) {
    return _contractFailure(
      'Der Herbarium-Eintrag enthält unvollständige Pflichtfelder.',
      const ['id', 'observedAt', 'version', 'syncStatus'],
    );
  }

  final identification = body['identification'];
  final mappedIdentification = identification is Map<String, dynamic>
      ? _identification(identification)
      : null;
  if (identification != null && mappedIdentification == null) {
    return _contractFailure(
      'Die Identifikation eines Herbarium-Eintrags ist ungültig.',
      const ['identification'],
    );
  }
  final candidate = _confirmedCandidate(mappedIdentification);
  return Result.success(
    HerbariumEntry(
      id: id,
      observedAt: observedAt,
      note: _optionalString(body, 'note') ?? '',
      confirmedPlantId: _optionalString(body, 'confirmedPlantId'),
      identificationJobId: mappedIdentification?.id,
      identificationResult: _identificationLabel(candidate),
      plantName: candidate?.commonName,
      scientificName: candidate?.scientificName,
      version: version,
      syncStatus: syncStatus,
    ),
  );
}

IdentificationJob? _identification(Map<String, dynamic> body) {
  final id = _requiredString(body, 'id');
  final status = _requiredString(body, 'status');
  final createdAt = _date(body['createdAt']);
  if (id == null || status == null || createdAt == null) return null;
  final candidates = <IdentificationCandidate>[];
  final rawCandidates = body['candidates'];
  if (rawCandidates != null && rawCandidates is! List) return null;
  if (rawCandidates is List) {
    for (final rawCandidate in rawCandidates) {
      if (rawCandidate is! Map<String, dynamic>) return null;
      final scientificName = _requiredString(rawCandidate, 'scientificName');
      final candidateId = _requiredString(rawCandidate, 'candidateId');
      final score = rawCandidate['score'];
      if (candidateId == null || scientificName == null || score is! num) {
        return null;
      }
      candidates.add(
        IdentificationCandidate(
          candidateId: candidateId,
          scientificName: scientificName,
          commonName: _optionalString(rawCandidate, 'commonName'),
          plantId: _optionalString(rawCandidate, 'plantId'),
          score: score.toDouble(),
          provider: _optionalString(rawCandidate, 'provider') ?? 'plantnet',
          modelVersion:
              _optionalString(rawCandidate, 'modelVersion') ?? 'unknown',
        ),
      );
    }
  }
  return IdentificationJob(
    id: id,
    status: status,
    createdAt: createdAt,
    candidates: candidates,
    confirmedPlantId: _optionalString(body, 'confirmedPlantId'),
    confirmedCandidateId: _optionalString(body, 'confirmedCandidateId'),
  );
}

IdentificationCandidate? _confirmedCandidate(IdentificationJob? job) {
  if (job == null || job.candidates.isEmpty) return null;
  final confirmedCandidateId = job.confirmedCandidateId;
  if (confirmedCandidateId != null) {
    for (final candidate in job.candidates) {
      if (candidate.candidateId == confirmedCandidateId) return candidate;
    }
  }
  final confirmedPlantId = job.confirmedPlantId;
  if (confirmedPlantId == null) return job.candidates.first;
  for (final candidate in job.candidates) {
    if (candidate.plantId == confirmedPlantId) return candidate;
  }
  return job.candidates.first;
}

String? _identificationLabel(IdentificationCandidate? candidate) {
  if (candidate == null) return null;
  final score = (candidate.score * 100).toStringAsFixed(0);
  return '${candidate.provider}: ${candidate.scientificName} ($score %)';
}

SyncStatus? _syncStatus(Object? value) => switch (value) {
  'synced' => SyncStatus.synced,
  'pending' => SyncStatus.pending,
  'conflict' => SyncStatus.conflict,
  'deleted' => SyncStatus.deleted,
  _ => null,
};

String? _requiredString(Map<String, dynamic> body, String key) {
  final value = body[key];
  return value is String && value.isNotEmpty ? value : null;
}

String? _optionalString(Map<String, dynamic> body, String key) {
  final value = body[key];
  return value is String && value.isNotEmpty ? value : null;
}

DateTime? _date(Object? value) =>
    value is String ? DateTime.tryParse(value)?.toLocal() : null;

Result<T> _contractFailure<T>(String message, List<String> missingFields) =>
    Result.failure(
      ContractFailure(message: message, missingFields: missingFields),
    );
