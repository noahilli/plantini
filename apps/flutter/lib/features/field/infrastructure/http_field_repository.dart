import 'dart:typed_data';

import '../../../adapters/http/platform_api_client.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/result.dart';
import '../domain/field_models.dart';
import '../domain/field_repository.dart';

/// HTTP adapter for the caller-owned media and identification v1 endpoints.
///
/// The adapter keeps the upload reservation and byte upload separate because
/// the server validates the exact content type and byte count it reserved.
final class HttpFieldRepository implements FieldRepository {
  const HttpFieldRepository(this._client);

  final PlatformApiClient _client;

  @override
  Future<Result<MediaUpload>> reserveMediaUpload({
    required String clientMediaId,
    required String contentType,
    required int bytes,
    required String idempotencyKey,
  }) async {
    final response = await _client.postJson(
      'media/uploads',
      idempotencyKey: idempotencyKey,
      body: {
        'clientMediaId': clientMediaId,
        'contentType': contentType,
        'bytes': bytes,
      },
    );
    return response.when(
      success: (value) => _mediaUpload(value.body),
      failure: Result.failure,
    );
  }

  @override
  Future<Result<MediaUpload>> uploadMediaContent({
    required String mediaId,
    required List<int> bytes,
    required String contentType,
    required String filename,
  }) async {
    final response = await _client.postMultipart(
      'media/uploads/$mediaId/content',
      fields: const {},
      bytes: Uint8List.fromList(bytes),
      mediaType: contentType,
      filename: filename,
    );
    return response.when(
      success: (value) => _mediaUpload(value.body),
      failure: Result.failure,
    );
  }

  @override
  Future<Result<IdentificationJob>> submitObservation({
    required String clientJobId,
    required String mediaId,
    String? expectedPlantId,
    required String idempotencyKey,
  }) async {
    final response = await _client.postJson(
      'identifications',
      idempotencyKey: idempotencyKey,
      body: {
        'clientJobId': clientJobId,
        'mediaId': mediaId,
        if (expectedPlantId != null) 'expectedPlantId': expectedPlantId,
      },
    );
    return response.when(
      success: (value) => _identificationJob(value.body),
      failure: Result.failure,
    );
  }

  @override
  Future<Result<IdentificationJob>> getIdentification(String jobId) async {
    final response = await _client.getJson('identifications/$jobId');
    return response.when(
      success: (value) => _identificationJob(value.body),
      failure: Result.failure,
    );
  }

  @override
  Future<Result<IdentificationJob>> confirmIdentification({
    required String jobId,
    String? candidateId,
    String? confirmedPlantId,
  }) async {
    final hasCandidateId = candidateId != null && candidateId.trim().isNotEmpty;
    final hasPlantId =
        confirmedPlantId != null && confirmedPlantId.trim().isNotEmpty;
    if (hasCandidateId == hasPlantId) {
      return const Result.failure(
        ValidationFailure(
          message:
              'Bitte bestätige genau einen Pflanzenkandidaten für diesen Fund.',
        ),
      );
    }
    final response = await _client.postJson(
      'identifications/$jobId/confirm',
      body: {
        if (hasCandidateId) 'candidateId': candidateId,
        if (hasPlantId) 'confirmedPlantId': confirmedPlantId,
      },
    );
    return response.when(
      success: (value) => _identificationJob(value.body),
      failure: Result.failure,
    );
  }
}

Result<MediaUpload> _mediaUpload(Map<String, dynamic> body) {
  final id = _requiredString(body, 'id');
  final expiresAt = _date(body['expiresAt']);
  final status = _requiredString(body, 'status');
  if (id == null || expiresAt == null || status == null) {
    return _contractFailure(
      'Die Upload-Antwort enthält unvollständige Pflichtfelder.',
      const ['id', 'expiresAt', 'status'],
    );
  }
  return Result.success(
    MediaUpload(id: id, expiresAt: expiresAt, status: status),
  );
}

Result<IdentificationJob> _identificationJob(Map<String, dynamic> body) {
  final id = _requiredString(body, 'id');
  final status = _requiredString(body, 'status');
  final createdAt = _date(body['createdAt']);
  if (id == null || status == null || createdAt == null) {
    return _contractFailure(
      'Die Identifikationsantwort enthält unvollständige Pflichtfelder.',
      const ['id', 'status', 'createdAt'],
    );
  }

  final candidates = <IdentificationCandidate>[];
  final rawCandidates = body['candidates'];
  if (rawCandidates != null) {
    if (rawCandidates is! List) {
      return _contractFailure('candidates muss eine Liste sein.', const [
        'candidates',
      ]);
    }
    for (var index = 0; index < rawCandidates.length; index++) {
      final rawCandidate = rawCandidates[index];
      if (rawCandidate is! Map<String, dynamic>) {
        return _contractFailure('Ein Identifikationskandidat ist ungültig.', [
          'candidates[$index]',
        ]);
      }
      final candidateId = _requiredString(rawCandidate, 'candidateId');
      final scientificName = _requiredString(rawCandidate, 'scientificName');
      final score = rawCandidate['score'];
      if (candidateId == null || scientificName == null || score is! num) {
        return _contractFailure(
          'Ein Identifikationskandidat ist unvollständig.',
          [
            'candidates[$index].candidateId',
            'candidates[$index].scientificName',
            'candidates[$index].score',
          ],
        );
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

  return Result.success(
    IdentificationJob(
      id: id,
      status: status,
      createdAt: createdAt,
      retryAfter: _date(body['retryAfter']),
      candidates: candidates,
      failureCode: _optionalString(body, 'failureCode'),
      confirmedPlantId: _optionalString(body, 'confirmedPlantId'),
      confirmedCandidateId: _optionalString(body, 'confirmedCandidateId'),
    ),
  );
}

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
