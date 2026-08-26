import '../../../core/result.dart';
import '../domain/field_models.dart';
import '../domain/field_repository.dart';

/// Submits an observation for plant identification.
final class SubmitObservation {
  const SubmitObservation(this._repository);

  final FieldRepository _repository;

  Future<Result<IdentificationJob>> call({
    required String clientJobId,
    required String mediaId,
    String? expectedPlantId,
    required String idempotencyKey,
  }) =>
      _repository.submitObservation(
        clientJobId: clientJobId,
        mediaId: mediaId,
        expectedPlantId: expectedPlantId,
        idempotencyKey: idempotencyKey,
      );
}

/// Retrieves the status and result candidates of an identification job.
final class GetIdentificationStatus {
  const GetIdentificationStatus(this._repository);

  final FieldRepository _repository;

  Future<Result<IdentificationJob>> call(String jobId) =>
      _repository.getIdentification(jobId);
}
