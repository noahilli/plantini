import '../../../core/result.dart';
import 'field_models.dart';

/// Contract for field observations and plant identification service.
abstract interface class FieldRepository {
  Future<Result<IdentificationJob>> submitObservation({
    required String clientJobId,
    required String mediaId,
    String? expectedPlantId,
    required String idempotencyKey,
  });

  Future<Result<IdentificationJob>> getIdentification(String jobId);

  Future<Result<IdentificationJob>> confirmIdentification({
    required String jobId,
    required String confirmedPlantId,
  });
}
